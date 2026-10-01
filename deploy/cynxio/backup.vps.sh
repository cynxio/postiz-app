#!/bin/bash
set -euo pipefail
umask 077
exec 9>/run/cynxio-postiz-backup.lock
flock -n 9 || exit 0
cd /opt/cynxio/postiz/deploy/cynxio
compose=(docker compose -f compose.yaml -f compose.vps.yaml)
backup_root=/var/backups/cynxio-postiz
install -d -m 700 "$backup_root"
backup_work=$(mktemp -d "$backup_root/.working-XXXXXX")
trap 'rm -rf "$backup_work"' EXIT
stamp=$(date -u +%Y%m%dT%H%M%SZ)
snapshot="backup-$(date -u +%Y%m%dt%H%M%Sz)"
es() {
  "${compose[@]}" exec -T temporal-elasticsearch curl -fsS --max-time 300 "$@"
}
es -X PUT http://localhost:9200/_snapshot/cynxio -H 'Content-Type: application/json' \
  -d '{"type":"fs","settings":{"location":"/snapshots","compress":true}}' > /dev/null
es -X PUT "http://localhost:9200/_snapshot/cynxio/$snapshot?wait_for_completion=true" \
  > "$backup_work/elasticsearch-snapshot.json"
python3 - "$backup_work/elasticsearch-snapshot.json" <<'PY'
import json, sys
assert json.load(open(sys.argv[1]))['snapshot']['state'] == 'SUCCESS'
PY
"${compose[@]}" exec -T postiz-postgres pg_dump -U postiz-user -d postiz-db-local -Fc > "$backup_work/postiz.dump"
"${compose[@]}" exec -T temporal-postgresql pg_dump -U temporal -d temporal -Fc > "$backup_work/temporal.dump"
cp .env compose.yaml compose.vps.yaml ingress.vps.yaml "$backup_work/"
cp -r ../../dynamicconfig "$backup_work/"
for name in postiz-config postiz-uploads es-snapshots; do
  docker run --rm --network none -v "cynxio-postiz_$name:/source:ro" \
    --entrypoint tar postgres:17-alpine -czf - -C /source . > "$backup_work/$name.tar.gz"
done
k3s kubectl -n cynxio-social get secret postiz-tls letsencrypt-account -o json > "$backup_work/tls.json"
(cd "$backup_work" && find . -type f ! -name SHA256SUMS -print0 | sort -z | xargs -0 sha256sum > SHA256SUMS)
target="$backup_root/postiz-$stamp.tar.cms"
tar -C "$backup_work" -cf - . | openssl cms -encrypt -binary -aes-256-gcm \
  -outform DER -out "$target.partial" /etc/cynxio/backup-recipient.pem
mv "$target.partial" "$target"
ln -sfn "$(basename "$target")" "$backup_root/latest.tar.cms"
# The archive owns this completed snapshot; remove it through Elasticsearch.
es -X DELETE "http://localhost:9200/_snapshot/cynxio/$snapshot" > /dev/null
find "$backup_root" -maxdepth 1 -type f -name 'postiz-*.tar.cms' -mtime +14 -delete
printf 'Encrypted Postiz backup completed: %s\n' "$stamp"

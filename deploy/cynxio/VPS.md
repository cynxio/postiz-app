# Cynxio Postiz VPS

Active URL: https://social.internal.cynxio.com. Migrated on 1 October 2026.
The existing email/password account and seven integrations were preserved.
Google sign-in is a different Postiz identity; it cannot create an account while
registration is closed. Use the existing email/password login.

## Runtime

- VPS: `cynx@152.53.165.241`, directory `/opt/cynxio/postiz` (root-owned).
- Compose project: `cynxio-postiz`, six services, persistent named volumes.
- Run from `/opt/cynxio/postiz/deploy/cynxio` using both files:

  ```sh
  docker compose -f compose.yaml -f compose.vps.yaml ps
  docker compose -f compose.yaml -f compose.vps.yaml up -d --wait
  ```

- Same pinned upstream v2.24.0 multi-architecture image as the local install.
  This deployment does not build the fork's newer main branch.
- Private `.env` is mode 0600, retaining all original keys and encryption secrets.
  Never print resolved Compose configuration or commit secrets.
- Registration is disabled, HTTPS cookies enabled. Only the VPS scheduler runs.
- DNS: dedicated DNS-only A record, `social.internal` -> `152.53.165.241`.
  Existing `internal.cynxio.com` and its wildcard were left unchanged.
- TLS: namespaced cert-manager Let's Encrypt issuer, automatic HTTP-01 renewal.
  Cloudflare Universal SSL does not cover this nested hostname, so this host
  uses direct HTTPS rather than the Cloudflare proxy.
- Traefik resources are in the separate `cynxio-social` namespace. HTTP redirects
  to HTTPS, apart from ACME challenge routes. Other applications were unchanged.
- Docker's external `cynxio-postiz-ingress` bridge has subnet `172.30.40.0/24`,
  gateway `172.30.40.1`. Only that private address publishes port 4007; the
  Kubernetes Service/EndpointSlice routes Traefik to it. No database or scheduler
  port is published. Create the bridge before starting this Compose overlay:

  ```sh
  docker network create --subnet 172.30.40.0/24 --gateway 172.30.40.1 cynxio-postiz-ingress
  ```

## Migration and rollback

Stopped the Mac Postiz and Temporal workers before taking logical dumps of both
databases. Stopped the remaining local services before archiving Redis,
Elasticsearch, config and uploads. Restored into fresh VPS volumes, preserving
tokens and account IDs. `migrate-public-urls.sql` changed five integration avatar
URLs from localhost to the new host; no Media rows needed changes.

Migration backup on Mac:
`~/.local/share/cynxio/backups/postiz-migration-20261001T112527/`.
Root-only server copy: `/var/backups/cynxio-postiz/migration-20261001/`.
The stopped Mac containers and volumes remain intact. Never use `down -v`.

Before rolling back, stop the VPS scheduler first. If any account/token/content
changes occurred on the VPS, take and restore a fresh backup rather than running
the stale local database. Restore local callback configuration if needed (Kick's
single callback was replaced; the other four retain their localhost entries).
Starting the Mac alone does not route the public hostname there.

## Backups

`cynxio-postiz-backup.timer` runs daily at 02:45 UTC with up to five minutes of
jitter and catches up missed runs. The script stores both logical database dumps,
an Elasticsearch native snapshot, config/uploads, private runtime configuration,
TLS secrets and checksums. It uses the existing Cynxio public recovery certificate
to encrypt with AES-256-GCM. The private recovery key stays on the Mac.

Encrypted files: `/var/backups/cynxio-postiz/postiz-*.tar.cms`, retained 14 days;
`latest.tar.cms` points to the latest completed archive. A verified off-host copy
is at `~/.local/share/cynxio/backups/postiz-20261001.tar.cms`. Automatic off-host
collection for Postiz is not installed; the existing accounts collector handles
only account backups. Redis is disposable cache in daily recovery; the migration
snapshot additionally preserves its stopped volume.

Database dumps and the Elasticsearch snapshot are individually consistent, not a
single transaction across services. Stop workers during a planned restore. Restore
databases into fresh volumes, uploads/config into matching volumes, and Elasticsearch
through its native snapshot API before starting workers. Preserve `.env` secrets.

```sh
systemctl start cynxio-postiz-backup.service
systemctl status cynxio-postiz-backup.timer
```

## Verification

Passed: Compose validation, Kubernetes server-side validation, six healthy
services, Temporal SERVING, public trusted HTTPS, HTTP redirect, secure-cookie
configuration, registration closed, anonymous API rejection, public media
retrieval, and the owner-authenticated calendar with all seven migrated channels plus
the newly connected TikTok sandbox channel.
Production accounts/websites remained available. The original database dump
restored successfully into a disposable isolated PostgreSQL container with one
user and seven integrations. The encrypted backup decrypted off-host and all 13
file checksums passed. The local stack remains stopped.

Provider callback configuration was updated for YouTube, X, Instagram, Threads
and Kick. DEV.to and Hashnode use the preserved API tokens. TikTok sandbox setup
is recorded in [provider status](README.md#provider-setup-status-1-october-2026).
No real post was published. Token refresh, each provider's live publishing and
end-to-end scheduled delivery are not established by these migration checks.

This is deployment of the existing upstream tool, with no application or UI code
changes. Product design and application feature/build gates are not applicable;
verification covers migration, runtime, public routing, authentication and backups.

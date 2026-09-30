# Cynxio local Postiz

Free self-hosted installation. No Postiz Cloud subscription or trial is used.
This configuration installs the upstream v2.24.0 ARM64/AMD64 release image,
pinned by digest. It does not build the fork's current main branch. Future
application customizations need a separately built image before they take effect.

## Start

From this directory:

```sh
python3 setup.py
docker compose config --quiet
docker compose pull
docker compose up -d --wait --wait-timeout 300
```

Open http://localhost:4007 and create your local account. Use `localhost`
consistently for login cookies. Setup generates private credentials in the ignored
`.env`, with mode 0600, and preserves them on subsequent runs. Never commit it or
print the resolved Compose configuration, which contains secrets.

Registration is restricted by default (`DISABLE_REGISTRATION=true`). Upstream
allows the first organization to be created when the database is empty, then
blocks additional local registrations. Create your own account when first opening
this loopback-bound installation.

## Operations

```sh
docker compose ps
docker compose logs --tail=80 postiz
docker compose stop
docker compose start
```

Project name: `cynxio-postiz`. The only published port is
`127.0.0.1:4007`. PostgreSQL, Redis, Elasticsearch and Temporal are reachable only
on the isolated Compose networks. All application and scheduler state uses
project-scoped named volumes. Stop/start preserves accounts and uploaded files.
Do not use `down -v` unless deliberately deleting this installation's data.

This is local tool setup, with upstream UI and application behavior unchanged.
Product design, feature implementation and application regression/build gates
are not applicable to installing the prebuilt upstream release. Verification
covers Compose configuration, runtime health, registration UI and authentication
reachability, not social publishing.

## Social connections and public hosting

No social accounts or external publishing credentials are configured initially.
Add the appropriate provider variables to the ignored `.env`, then recreate the
Postiz service. Provider app setup and applicable reviews are still required.

- Meta: `FACEBOOK_APP_ID`, `FACEBOOK_APP_SECRET`, or standalone Instagram
  `INSTAGRAM_APP_ID`, `INSTAGRAM_APP_SECRET`.
- Threads: `THREADS_APP_ID`, `THREADS_APP_SECRET`.
- YouTube: `YOUTUBE_CLIENT_ID`, `YOUTUBE_CLIENT_SECRET`.
- TikTok: `TIKTOK_CLIENT_ID`, `TIKTOK_CLIENT_SECRET`.
- X: `X_API_KEY`, `X_API_SECRET`.

Some providers need publicly reachable HTTPS callbacks and media URLs. This
localhost setup does not satisfy those requirements. Public deployment is a
separate step: configure HTTPS, matching frontend/API/callback URLs, secure
cookies (remove `NOT_SECURED`), restricted registration, backups and reachable
media storage before connecting those providers. Do not simply expose port 4007.

Upstream references:

- https://docs.postiz.com/self-host/installation/docker-compose
- https://github.com/gitroomhq/postiz-docker-compose
- https://docs.postiz.com/self-host/configuration/reference

The Compose file is derived from the official Compose configuration on
30 September 2026. Debug tools and the Temporal
UI are omitted; the scheduler and its persistent storage remain included.

## Verification status (30 September 2026)

Passed: Compose validation, single loopback port, project-scoped networks and
volumes, private ignored secrets, and non-destructive setup rerun. Image pulls
and startup completed; all six services are healthy. Backend, frontend and
orchestrator are online, Temporal reports SERVING, and the main task queue has
an active worker poller.

A synthetic local account verified first-account registration, authenticated
identity, anonymous API rejection, wrong-password rejection, registration
closing after the first account, browser login and the rendered calendar with
no browser page errors. The synthetic user and organization were removed;
first-account registration is available again at http://localhost:4007.

No social accounts are connected. OAuth callbacks, media uploads, scheduled
publishing and public hosting have not been verified. This installation runs
the pinned upstream image; source customizations require building and selecting
a replacement image from this fork.

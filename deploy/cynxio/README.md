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

A fresh installation has no social accounts or external publishing credentials.
Add the appropriate provider variables to the ignored `.env`, then recreate the
Postiz service. Provider app setup and applicable reviews are still required.

- Meta: `FACEBOOK_APP_ID`, `FACEBOOK_APP_SECRET`, or standalone Instagram
  `INSTAGRAM_APP_ID`, `INSTAGRAM_APP_SECRET`.
- Threads: `THREADS_APP_ID`, `THREADS_APP_SECRET`.
- YouTube: `YOUTUBE_CLIENT_ID`, `YOUTUBE_CLIENT_SECRET`.
- TikTok: `TIKTOK_CLIENT_ID`, `TIKTOK_CLIENT_SECRET`.
- X: `X_API_KEY`, `X_API_SECRET`.
- Reddit: `REDDIT_CLIENT_ID`, `REDDIT_CLIENT_SECRET`.
- Kick: `KICK_CLIENT_ID`, `KICK_SECRET`.
- Twitch: `TWITCH_CLIENT_ID`, `TWITCH_CLIENT_SECRET`.
- DEV.to and Hashnode: enter the account API token through Add Channel.

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

## Provider setup status (1 October 2026)

- YouTube: connected as Cynxio (`@thecynxio`). Dedicated OAuth client
  `Cynxio Postiz Local` in the existing `cynxio-509303` Google project; the
  existing website client is unchanged. YouTube Data, Analytics and Reporting
  APIs are enabled. Callback: `http://localhost:4007/integrations/social/youtube`.
- X: connected as Cynxio (`thecynxio`). Developer app `33486181`, OAuth 1.0a
  read/write permissions, callback `http://localhost:4007/integrations/social/x`.
  The developer console reports Pay Per Use with a zero credit balance.
  Connection success does not establish publishing or analytics entitlement.
- Instagram: connected as Cynxio (`thecynxio`) through the standalone provider.
  Meta app `Cynxio Social` (`1613116090270195`), Instagram app ID
  `4478709349012116`. Basic, content publishing, comment management and
  insights permissions are enabled for testing. The account accepted the
  Instagram Tester invitation; the app remains unpublished.
  The account was converted to a public Business professional account,
  category Software Company, with category and contact details not displayed.
  Local callback registered exactly as generated by upstream Postiz:
  `https://redirectmeto.com/http://localhost:4007/integrations/social/instagram-standalone`.
  This upstream local-login flow uses an external redirect service. A future
  public HTTPS deployment should use its own direct callback instead.

- DEV.to: connected as Cynxio (`cynxio`) using the `Cynxio Postiz Local` API key.
  Profile: https://dev.to/cynxio.
- Hashnode: connected as Cynxio (`cynxio`) with a personal access token.
  Profile: https://hashnode.com/@cynxio. Created publication
  https://thecynxio.hashnode.dev (`6abd5c257a9ea1114ae77f72`);
  `cynxio.hashnode.dev` was unavailable.
- Medium: skipped at the owner's request. Profile https://medium.com/@cynxio verified. Not connected:
  Medium no longer issues new integration tokens. An existing legacy token
  would be required: https://help.medium.com/hc/en-us/articles/213480228-API-Importing.
- Threads: added the Threads use case to Cynxio Social, app ID
  `1446204587390155`. Setup pending Meta password reauthentication to reveal
  the secret, callback registration, tester enrollment and OAuth connection.
- Reddit: prepared a separate web app registration for `Cynxio Postiz Local`,
  callback `http://localhost:4007/integrations/social/reddit`. Registration
  returned a Responsible Builder Policy notice. Reddit requires explicit API
  approval before access; commercial use requires written approval.
  Policy: https://support.reddithelp.com/hc/en-us/articles/42728983564564-Responsible-Builder-Policy.
  The unrelated research-app draft is preserved. No access request has been sent.
- Kick: developer app creation requires enabling two-factor authentication.
- Twitch: developer-console sign-in is pending.
- TikTok: developer-account sign-in is pending. Public HTTPS callbacks and
  verified media URLs are also required; the localhost installation is not
  ready for public TikTok publishing.

The owner subsequently reported completing Meta reauthentication, Kick 2FA,
and Twitch/TikTok developer sign-ins. Browser page control timed out before
these could be verified or app setup continued. Recheck the existing signed-in
tabs; do not ask the owner to repeat those steps without observing a new gate.

App secrets and token backups are stored in the ignored, mode-0600
`deploy/cynxio/.env`, which the Postiz service loads via `env_file`. Connected
channel tokens are also held in Postiz's private database. All five connected
channels are enabled and are not flagged for reauthorization in Postiz.
No test posts or videos have been published.
Public media delivery and end-to-end scheduled publishing remain unverified.

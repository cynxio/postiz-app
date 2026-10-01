# Cynxio Postiz

The active installation is https://social.internal.cynxio.com on the Cynxio VPS.
The original Mac installation is stopped and retained as a fallback. Do not start
both schedulers. See [VPS operations and migration](VPS.md).

Free self-hosted installation. No Postiz Cloud subscription or trial is used.
This configuration installs the upstream v2.24.0 ARM64/AMD64 release image,
pinned by digest. It does not build the fork's current main branch. Future
application customizations need a separately built image before they take effect.

## Local installation (fallback)

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
  APIs are enabled. Public callback: `https://social.internal.cynxio.com/integrations/social/youtube`.
  The original localhost callback is retained for rollback.
- X: connected as Cynxio (`thecynxio`). Developer app `33486181`, OAuth 1.0a
  read/write permissions, public callback
  `https://social.internal.cynxio.com/integrations/social/x`. The localhost
  callback is retained for rollback.
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
  Added direct public callback
  `https://social.internal.cynxio.com/integrations/social/instagram-standalone`.
  The localhost callback is retained for rollback.

- DEV.to: connected as Cynxio (`cynxio`) using the `Cynxio Postiz Local` API key.
  Profile: https://dev.to/cynxio.
- Hashnode: connected as Cynxio (`cynxio`) with a personal access token.
  Profile: https://hashnode.com/@cynxio. Created publication
  https://thecynxio.hashnode.dev (`6abd5c257a9ea1114ae77f72`);
  `cynxio.hashnode.dev` was unavailable.
- Medium: skipped at the owner's request. Profile https://medium.com/@cynxio verified. Not connected:
  Medium no longer issues new integration tokens. An existing legacy token
  would be required: https://help.medium.com/hc/en-us/articles/213480228-API-Importing.
- Threads: connected as `thecynxio` through Cynxio Social, app ID
  `1446204587390155`. Registered callback
  `https://redirectmeto.com/http://localhost:4007/integrations/social/threads`
  plus `https://social.internal.cynxio.com/integrations/social/threads`,
  and accepted the `thecynxio` Threads Tester invitation. The owner supplied
  the secret, which was saved only to the private ignored environment file.
  OAuth completed and the channel is enabled without a reauthorization flag.
- Reddit: skipped at the owner's request after the following attempt.
  Prepared a separate web app registration for `Cynxio Postiz Local`,
  callback `http://localhost:4007/integrations/social/reddit`. Registration
  returned a Responsible Builder Policy notice. Reddit requires explicit API
  approval before access; commercial use requires written approval.
  Policy: https://support.reddithelp.com/hc/en-us/articles/42728983564564-Responsible-Builder-Policy.
  The unrelated research-app draft is preserved. A separate commercial API
  access request was prepared in Reddit Help for internal, human-reviewed
  Postiz scheduling. The owner approved submission and it was attempted;
  the site returned the populated form without confirmation or a ticket number.
  No acknowledgement was found in the work inbox. Delivery is unconfirmed;
  do not treat this as an approved or successfully submitted API application.
- Kick: connected as `cynxio`. Created app `cynxio` after the owner enabled 2FA.
  Callback `https://social.internal.cynxio.com/integrations/social/kick`; requested scopes
  `user:read`, `channel:read`, and `chat:write`. This provider publishes chat
  messages, not videos.
- Twitch: skipped at the owner's request. Signed in as `thecynxio`. Prepared `Cynxio Postiz Local`, category
  Chat Bot, confidential client, callback
  `http://localhost:4007/integrations/social/twitch`. Creation returned
  `user must have two factor auth enabled to perform this action`.
  Opened Twitch 2FA enrollment. The owner's phone attempt returned
  `We weren't able to register two-factor authentication for your phone number.`
  Twitch 2FA remains disabled; app creation cannot finish yet.
- TikTok: app `Cynxio` (`7691453308287862804`), sandbox `Cynxio Local`
  (`7691524823546939412`). Saved the owner-uploaded icon, Social Networking
  category, Web platform, honest private-use description, website, Terms and
  Privacy URLs, Login Kit, Content Posting API / Direct Post, and six scopes.
  Callback: `https://social.internal.cynxio.com/integrations/social/tiktok`.
  TikTok verified `cynxio.com` by DNS, covering its subdomains, as well as the
  earlier `https://cynxio.com/` URL prefix. Sandbox credentials are installed
  privately on the VPS. Authorized `thecynxio` as a sandbox target user and
  completed OAuth from the hosted Postiz instance. The channel is connected
  without a reauthorization flag. This is sandbox access; no app audit or
  publishing has been completed.
  TikTok's Direct Post guidelines exclude internal/private team upload tools
  from the intended use for audited public posting:
  https://developers.tiktok.com/doc/content-sharing-guidelines.
  Normal TikTok publishing uses Buffer Cloud Free instead:
  https://publish.buffer.com/channels/6abdfc76ea19ca0bde3fb62c/schedule.
  Connected `@thecynxio` on 1 October 2026; Free plan, Automatic publishing
  mode and Jakarta timezone verified. No posts or drafts created. The existing
  Postiz sandbox connection is retained for testing.

- Mastodon: connected as `cynxio` on `mastodon.social` on 1 October 2026.
  Profile: https://mastodon.social/@cynxio. App `Cynxio Postiz` (`9245067`)
  uses `profile`, `write:media` and `write:statuses`, with callback
  `https://social.internal.cynxio.com/integrations/social/mastodon`.
  Credentials are installed privately on the VPS; Postiz was recreated and
  became healthy. OAuth completed and the channel appears in the calendar.

Existing browser-tab attachment stalled; fresh tabs in the same Cynxio Brave
profile restored control and preserved the signed-in sessions.

App secrets and token backups are stored in the ignored, mode-0600
`deploy/cynxio/.env`, which the Postiz service loads via `env_file`. Connected
channel tokens are also held in Postiz's private database. The eight earlier
channels were verified enabled without reauthorization flags; Mastodon is now
the ninth connected channel, verified in the hosted calendar.
No test posts or videos have been published.
Public HTTPS media delivery passed after migration. End-to-end scheduled
publishing remains unverified.

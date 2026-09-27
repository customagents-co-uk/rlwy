# Founder Edition — Complete Single-Service Railway Deployment

This is the complete single-container Founder stack:

```text
Railway HTTPS
      |
      v
+-------------------------------+
| Founder container             |
|                               |
| Paperclip :$PORT              |
|   |                           |
|   +-- Company control plane   |
|   +-- Tasks / issues / goals  |
|   +-- Embedded PostgreSQL     |
|                               |
| Hermes gateway :8642          |
|   |                           |
|   +-- Founder agent           |
|   +-- browser/web/tools       |
|   +-- memory/workspace        |
|   +-- OpenRouter              |
|                               |
| /data persistent volume       |
+-------------------------------+
```

## 1. Railway deployment

Create ONE Railway service from this repository.

Add a Railway Volume mounted at:

```text
/data
```

Set:

```text
OPENROUTER_API_KEY=your-key
FOUNDER_MODEL=anthropic/claude-sonnet-4.6
PAPERCLIP_DEPLOYMENT_MODE=authenticated
PAPERCLIP_DEPLOYMENT_EXPOSURE=public
PAPERCLIP_AUTH_PUBLIC_BASE_URL=https://YOUR-RAILWAY-DOMAIN
```

After generating the Railway domain, put that exact HTTPS URL into
`PAPERCLIP_AUTH_PUBLIC_BASE_URL` and redeploy.

Paperclip's public authenticated mode requires an explicit public base URL.
Do not expose the service publicly in `local_trusted` mode.

## 2. First startup

The container will:

1. Create persistent directories.
2. Install the Founder operating system.
3. Install the Founder skill pack.
4. Configure Hermes for OpenRouter.
5. Generate a private Hermes gateway key if one is not supplied.
6. Onboard Paperclip.
7. Run Paperclip diagnostics/repair.
8. Start Paperclip.
9. Start the authenticated Hermes gateway.
10. Keep both processes supervised.

Railway healthchecks `/health`.

## 3. Connect Hermes to Paperclip

Paperclip's Hermes integration intentionally uses a secure two-key model:

- Hermes inference key: e.g. `OPENROUTER_API_KEY`
- Hermes gateway key: `API_SERVER_KEY`
- Paperclip agent key: created after the Paperclip join request is approved

Do NOT reuse the Hermes gateway key as the Paperclip agent key.

After deployment, shell into the container and obtain the gateway key:

```bash
/opt/founder-scripts/show-hermes-key.sh
```

Then create the join request:

```bash
export COMPANY_ID="YOUR_PAPERCLIP_COMPANY_ID"
export HERMES_GATEWAY_API_KEY="$(/opt/founder-scripts/show-hermes-key.sh)"
/opt/founder-scripts/connect-hermes.sh
```

Approve the resulting pending Hermes agent request in Paperclip.

Then claim its one-time Paperclip API key:

```bash
npx paperclipai join list \
  --company-id "$COMPANY_ID" \
  --status pending_approval

npx paperclipai join approve REQUEST_ID \
  --company-id "$COMPANY_ID"

npx paperclipai join claim-key REQUEST_ID \
  --claim-secret CLAIM_SECRET
```

Store the resulting Paperclip agent key in Hermes' secure runtime state as
`PAPERCLIP_API_KEY`. The exact claim output should never be pasted into an
issue, log, source file, or prompt.

## 4. Founder skills

The image includes a curated Founder skill pack covering:

- Market research
- Customer discovery
- Product validation
- Product management
- Engineering
- DevOps
- Growth
- Sales
- Finance/operations
- Security
- Analytics
- Automation
- Web research
- Browser-agent workflows

Hermes also installs its own native skill/tool ecosystem.

## 5. Local development

```bash
cp .env.example .env
```

For local use, set:

```text
PAPERCLIP_DEPLOYMENT_MODE=local_trusted
PAPERCLIP_DEPLOYMENT_EXPOSURE=private
```

Then:

```bash
docker compose up --build
```

Open:

```text
http://localhost:3100
```

## 6. Backups

Inside the running container:

```bash
/opt/founder-scripts/backup.sh
```

This creates separate encrypted-at-rest-independent archive files for the
Hermes and Paperclip persistent directories. Protect the resulting backup
files as secrets because they contain application state.

## 7. Upgrade

The image intentionally has floating build arguments for the first deployment:

```text
PAPERCLIP_VERSION=latest
HERMES_BRANCH=main
```

Once the service is working, pin them to tested versions/commits in Railway
or the Dockerfile. This makes future rebuilds reproducible.

## 8. Important production boundary

The embedded PostgreSQL mode is deliberately used to keep this deployment
as ONE Railway service. It is appropriate for a single-instance Founder
deployment, but a larger production company should move PostgreSQL to a
managed database and keep `/data` for application state/storage.

## 9. Recovery

If the container is replaced, recreate the Railway Volume at `/data` or
restore the latest backup before starting.

If the Paperclip UI is healthy but Hermes is not:

```bash
tail -250 /data/hermes/logs/gateway.log
```

If Paperclip is not healthy:

```bash
tail -250 /data/paperclip/paperclip.log
paperclipai doctor
```

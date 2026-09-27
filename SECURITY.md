# Security model

## Public surface

Only Paperclip is intended to be reachable through Railway HTTPS.

Hermes API port 8642 binds inside the container and is not published by the
Dockerfile or Railway configuration.

## Credentials

Three credentials have different purposes:

1. Provider key — authorises model inference.
2. Hermes gateway key — authorises Paperclip -> Hermes.
3. Paperclip agent key — authorises Hermes -> Paperclip.

Never reuse them.

## Secrets

Do not:
- commit `.env`
- print gateway keys
- paste agent keys into issues
- put credentials in Founder prompts
- put provider keys into GitHub Actions logs

## External actions

The Founder operating system requires human approval for:
- purchases/spending
- contracts
- irreversible legal commitments
- high-impact external communications unless explicitly delegated

## Backups

The `/data` volume contains secrets and business state. Treat backups as
sensitive credentials.

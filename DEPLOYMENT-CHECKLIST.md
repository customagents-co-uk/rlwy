# Complete deployment checklist

## Railway
- [ ] One Railway service created.
- [ ] Dockerfile deployment selected.
- [ ] Volume mounted at `/data`.
- [ ] Railway public domain generated.
- [ ] `PAPERCLIP_AUTH_PUBLIC_BASE_URL` set to exact HTTPS domain.
- [ ] `OPENROUTER_API_KEY` set.
- [ ] `FOUNDER_MODEL` set.
- [ ] `PAPERCLIP_DEPLOYMENT_MODE=authenticated`.
- [ ] `PAPERCLIP_DEPLOYMENT_EXPOSURE=public`.

## Startup
- [ ] Build completes.
- [ ] Paperclip onboarding completes.
- [ ] Paperclip `/api/health` responds.
- [ ] Hermes gateway starts.
- [ ] `/health` responds HTTP 200.
- [ ] Paperclip UI opens.

## Hermes/Paperclip integration
- [ ] Company created.
- [ ] Hermes gateway key retrieved securely.
- [ ] Hermes invite created.
- [ ] Pending join request reviewed.
- [ ] Join request approved.
- [ ] One-time Paperclip agent key claimed.
- [ ] Paperclip agent key stored as a secret.
- [ ] Hermes agent appears in Paperclip.
- [ ] Test issue assigned to Founder Hermes.
- [ ] Hermes completes and reports the test task.

## Security
- [ ] No keys committed to Git.
- [ ] No gateway key pasted into Paperclip issues.
- [ ] No Paperclip agent key pasted into prompts/comments.
- [ ] Public deployment is authenticated.
- [ ] `/data` volume backups tested.
- [ ] Hermes gateway is not separately exposed to the Internet.
- [ ] Versions pinned after successful validation.

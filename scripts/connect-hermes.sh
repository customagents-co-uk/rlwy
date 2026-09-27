#!/usr/bin/env bash
set -Eeuo pipefail

# Run this INSIDE the deployed container after Paperclip has been initialized.
# It creates a Paperclip invite. Approval remains an explicit human action.

: "${COMPANY_ID:?Set COMPANY_ID to the Paperclip company ID}"
: "${HERMES_GATEWAY_API_KEY:?Set HERMES_GATEWAY_API_KEY to the Hermes gateway key}"
: "${PAPERCLIP_API_URL:=http://127.0.0.1:3100}"

NAME="${HERMES_AGENT_NAME:-Founder Hermes}"
CAPABILITIES="${HERMES_AGENT_CAPABILITIES:-Founder/CEO agent with terminal, file, web, browser, research, coding, and Paperclip task capabilities.}"

PAYLOAD="$(jq -cn \
  --arg name "$NAME" \
  --arg capabilities "$CAPABILITIES" \
  --arg key "$HERMES_GATEWAY_API_KEY" \
  --arg pc "$PAPERCLIP_API_URL" \
  '{
    requestType:"agent",
    agentName:$name,
    adapterType:"hermes_gateway",
    capabilities:$capabilities,
    agentDefaultsPayload:{
      apiBaseUrl:"http://127.0.0.1:8642",
      apiKey:$key,
      paperclipApiUrl:$pc,
      sessionKeyStrategy:"issue",
      timeoutSec:600
    }
  }')"

echo "[founder] Creating Hermes agent invite..."
npx paperclipai invite create --company-id "$COMPANY_ID" --payload-json "$PAYLOAD"
echo
echo "[founder] Next: inspect the invite and approve it from the Paperclip board."
echo "[founder] Then claim the one-time Paperclip agent key using:"
echo "  npx paperclipai join claim-key <REQUEST_ID> --claim-secret <CLAIM_SECRET>"
echo
echo "[founder] Do NOT reuse the Hermes gateway key as the Paperclip agent key."

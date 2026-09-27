#!/usr/bin/env bash
set -Eeuo pipefail
KEY_FILE="${HERMES_HOME:-/data/hermes}/.gateway-key"
if [[ ! -f "$KEY_FILE" ]]; then
  echo "No gateway key exists yet. Start the Founder service first." >&2
  exit 1
fi
cat "$KEY_FILE"
echo

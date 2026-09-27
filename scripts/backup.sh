#!/usr/bin/env bash
set -Eeuo pipefail
DEST="${1:-/tmp/founder-backup-$(date +%Y%m%d-%H%M%S)}"
mkdir -p "$DEST"
tar -C /data -czf "$DEST/hermes.tar.gz" hermes
tar -C /data -czf "$DEST/paperclip.tar.gz" paperclip
chmod 600 "$DEST"/*.tar.gz
echo "Backup written to $DEST"

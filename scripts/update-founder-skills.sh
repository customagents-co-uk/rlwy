#!/usr/bin/env bash
set -Eeuo pipefail
DEST="${HERMES_HOME:-/data/hermes}/skills"
mkdir -p "$DEST"
cp -R /opt/founder-skills/. "$DEST/"
touch "$DEST/.founder-installed"
echo "Founder skill pack updated."

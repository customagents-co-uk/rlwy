#!/usr/bin/env bash
set -Eeuo pipefail

export PORT="${PORT:-3100}"

export HOME="${HOME:-/data}"
export HERMES_HOME="${HERMES_HOME:-/data/hermes}"
export PAPERCLIP_HOME="${PAPERCLIP_HOME:-/data/paperclip}"
export PAPERCLIP_INSTANCE_ID="${PAPERCLIP_INSTANCE_ID:-default}"

# Hermes CLI installed by the official installer.
export PATH="/data/.local/bin:/root/.local/bin:/usr/local/bin:/usr/bin:/bin:${PATH:-}"

mkdir -p \
    "$HOME" \
    "$HERMES_HOME" \
    "$PAPERCLIP_HOME"

echo "========================================"
echo "Founder Agent"
echo "========================================"
echo "HOME:          $HOME"
echo "HERMES_HOME:   $HERMES_HOME"
echo "PAPERCLIP_HOME:$PAPERCLIP_HOME"
echo "PORT:          $PORT"
echo "========================================"

# --------------------------------------------------
# Locate Hermes
# --------------------------------------------------

if ! command -v hermes >/dev/null 2>&1; then
    echo "Hermes not found on PATH. Searching..."

    for candidate in \
        /data/.local/bin/hermes \
        /root/.local/bin/hermes \
        /usr/local/bin/hermes
    do
        if [ -x "$candidate" ]; then
            export PATH="$(dirname "$candidate"):$PATH"
            break
        fi
    done
fi

if ! command -v hermes >/dev/null 2>&1; then
    echo "ERROR: Hermes executable was not found."

    echo "PATH:"
    echo "$PATH"

    echo "Possible Hermes launchers:"
    find /data /root /usr/local \
        -type f \
        -name hermes \
        -perm -111 \
        2>/dev/null || true

    exit 1
fi

HERMES_BIN="$(command -v hermes)"

echo "Hermes: $HERMES_BIN"

# --------------------------------------------------
# Verify Hermes
# --------------------------------------------------

"$HERMES_BIN" --help >/dev/null

echo "Hermes CLI OK"

# --------------------------------------------------
# OpenRouter
# --------------------------------------------------

if [ -n "${OPENROUTER_API_KEY:-}" ]; then
    echo "Configuring OpenRouter..."

    hermes config set OPENROUTER_API_KEY \
        "$OPENROUTER_API_KEY"

    if [ -n "${FOUNDER_MODEL:-}" ]; then
        hermes config set model "$FOUNDER_MODEL"
    fi
else
    echo "WARNING: OPENROUTER_API_KEY is not set."
fi

# --------------------------------------------------
# Founder state
# --------------------------------------------------

if [ -d /opt/founder/skills ]; then
    mkdir -p "$HERMES_HOME/skills"

    cp -rn /opt/founder/skills/. \
        "$HERMES_HOME/skills/" 2>/dev/null || true
fi

# --------------------------------------------------
# Paperclip
# --------------------------------------------------

echo "Starting Paperclip..."

paperclipai onboard --yes || true
paperclipai doctor --repair || paperclipai doctor || true

paperclipai run &
PAPERCLIP_PID=$!

echo "Paperclip PID: $PAPERCLIP_PID"

# --------------------------------------------------
# Wait for Paperclip
# --------------------------------------------------

echo "Waiting for Paperclip..."

for i in $(seq 1 60); do
    if curl -fsS \
        "http://127.0.0.1:${PORT}/api/health" \
        >/dev/null 2>&1; then
        echo "Paperclip is ready."
        break
    fi

    if ! kill -0 "$PAPERCLIP_PID" 2>/dev/null; then
        echo "ERROR: Paperclip exited."
        wait "$PAPERCLIP_PID"
        exit 1
    fi

    sleep 2
done

# --------------------------------------------------
# Hermes Gateway
# --------------------------------------------------

echo "Starting Hermes Gateway..."

hermes gateway run \
    --replace \
    --accept-hooks &

HERMES_PID=$!

echo "Hermes PID: $HERMES_PID"

# --------------------------------------------------
# Supervisor
# --------------------------------------------------

while true; do

    if ! kill -0 "$PAPERCLIP_PID" 2>/dev/null; then
        echo "Paperclip stopped."
        kill "$HERMES_PID" 2>/dev/null || true
        wait "$PAPERCLIP_PID" || true
        exit 1
    fi

    if ! kill -0 "$HERMES_PID" 2>/dev/null; then
        echo "Hermes stopped."
        kill "$PAPERCLIP_PID" 2>/dev/null || true
        wait "$HERMES_PID" || true
        exit 1
    fi

    sleep 5
done

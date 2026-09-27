FROM node:24-bookworm

ARG PAPERCLIP_VERSION=latest

ENV HOME=/data \
    HERMES_HOME=/data/hermes \
    PAPERCLIP_HOME=/data/paperclip \
    PAPERCLIP_INSTANCE_ID=default \
    NODE_ENV=production \
    PATH=/data/.local/bin:/root/.local/bin:/usr/local/bin:/usr/bin:/bin

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    jq \
    ripgrep \
    python3 \
    python3-venv \
    ffmpeg \
    tini \
    && rm -rf /var/lib/apt/lists/*

# Persistent directories
RUN mkdir -p \
    /data \
    /data/hermes \
    /data/paperclip \
    /data/.local/bin

# Paperclip
RUN npm install -g "paperclipai@${PAPERCLIP_VERSION}"

# Hermes
#
# The official installer creates the CLI wrapper at:
#   ~/.local/bin/hermes
#
# HOME=/data therefore makes that:
#   /data/.local/bin/hermes
#
RUN curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

# Make absolutely sure the launcher is available system-wide.
RUN if [ -x /data/.local/bin/hermes ]; then \
        ln -sf /data/.local/bin/hermes /usr/local/bin/hermes; \
    elif [ -x /root/.local/bin/hermes ]; then \
        ln -sf /root/.local/bin/hermes /usr/local/bin/hermes; \
    else \
        echo "ERROR: Hermes installer did not create hermes launcher"; \
        find /data /root -type f -name hermes -perm -111 2>/dev/null || true; \
        exit 1; \
    fi

RUN command -v hermes && hermes --help >/dev/null

COPY founder/ /opt/founder/
COPY skills/ /opt/founder/skills/
COPY scripts/ /opt/founder/scripts/
COPY entrypoint.sh /usr/local/bin/founder-entrypoint

RUN chmod +x \
    /usr/local/bin/founder-entrypoint \
    /opt/founder/scripts/*.sh

EXPOSE 3100

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/founder-entrypoint"]

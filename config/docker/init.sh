#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/.."

SSH_KEY_LOCATION="${CONFIG_DIR}/vnc_rsa"
ENV_FILE="${CONFIG_DIR}/../.env"

# Generate and load SSH key used by Guacamole to access the file system of containers
if [[ ! -f "${SSH_KEY_LOCATION}" ]]; then
  ssh-keygen -t rsa -m PEM -f "${SSH_KEY_LOCATION}" -N "" -C guacamole-vnc
fi

if [[ -f "${ENV_FILE}" ]]; then
  echo ".env file was already generated"
  exit 0
fi

# Add public key to environment
SSH_PUBLIC_KEY=$(cat "${SSH_KEY_LOCATION}.pub")

set +e
POSTGRES_PASSWORD="$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32)"
VNC_PW="$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32)"
GRAFANA_PW="$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32)"
PORTAINER_PW="$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32)"
set -e

echo -n "${PORTAINER_PW}" > "${CONFIG_DIR}/portainer_password"

cat <<EOF >"${ENV_FILE}"
TEAM_LIMIT_MEM=2g
TEAM_LIMIT_CPU=2
SSH_PUBLIC_KEY=${SSH_PUBLIC_KEY}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
VNC_PW=${VNC_PW}
GRAFANA_PW=${GRAFANA_PW}
EOF
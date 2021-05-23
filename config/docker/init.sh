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

# Add public key to environment
SSH_PUBLIC_KEY=$(cat "${SSH_KEY_LOCATION}.pub")
grep -v "SSH_PUBLIC_KEY=" "${ENV_FILE}" >"${ENV_FILE}.new"
echo "SSH_PUBLIC_KEY=${SSH_PUBLIC_KEY}" >>"${ENV_FILE}.new"
mv "${ENV_FILE}.new" "${ENV_FILE}"

# Change default postgres password
if grep "POSTGRES_PASSWORD=ChooseYourOwnPasswordHere1234" "${ENV_FILE}" >/dev/null; then
  set +e
  POSTGRES_PASSWORD="$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32)"
  set -e
  grep -v "POSTGRES_PASSWORD=" "${ENV_FILE}" >"${ENV_FILE}.new"
  echo "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}" >>"${ENV_FILE}.new"
  mv "${ENV_FILE}.new" "${ENV_FILE}"
fi

# Change default VNC password
if grep "VNC_PW=vncpassword" "${ENV_FILE}" >/dev/null; then
  set +e
  VNC_PW="$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 32)"
  set -e
  grep -v "VNC_PW=" "${ENV_FILE}" >"${ENV_FILE}.new"
  echo "VNC_PW=${VNC_PW}" >>"${ENV_FILE}.new"
  mv "${ENV_FILE}.new" "${ENV_FILE}"
fi

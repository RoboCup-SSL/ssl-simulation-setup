#!/usr/bin/env bash

# Read all passwords and generate password hashes for Caddy and put them into a new file

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/.."

touch "${CONFIG_DIR}/caddy_passwords"

while IFS=':' read -ra ADDR; do
  username=${ADDR[0]}
  password=${ADDR[1]}
  if ! grep "${username}" "${CONFIG_DIR}/caddy_passwords"; then
    hashed_password=$(docker run caddy:2.2.1-alpine caddy hash-password --plaintext "${password}")
    echo "${username}:${hashed_password}"
  fi
done <"${CONFIG_DIR}/passwords" | tee "${CONFIG_DIR}/caddy_passwords_"

mv "${CONFIG_DIR}/caddy_passwords_" "${CONFIG_DIR}/caddy_passwords"
cp "${CONFIG_DIR}/caddy_passwords" "${CONFIG_DIR}/caddy_passwords_active"

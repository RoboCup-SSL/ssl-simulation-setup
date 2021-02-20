#!/usr/bin/env bash

# Read all passwords and generate password hashes for Caddy and put them into a new file

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/.."

while IFS=':' read -ra ADDR; do
  username=${ADDR[0]}
  password=${ADDR[1]}
  hashed_password=$(docker run caddy:2.2.1-alpine caddy hash-password --plaintext "${password}")
  echo "${username}:${hashed_password}"
done <"${CONFIG_DIR}/passwords" | tee "${CONFIG_DIR}/caddy_passwords"

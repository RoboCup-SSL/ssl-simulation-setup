#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Get the generated local CA from caddy from inside the running container
docker cp ssl-simulation-setup_caddy_1:/data/caddy/pki/authorities/local/root.crt "${SCRIPT_DIR}/local-ca.crt"

# The CA can now be installed in your system or in your web browser directly

# For Arch Linux and Fedora, this command should install the CA system wide (a browser restart may be required)
sudo trust anchor --store "${SCRIPT_DIR}/local-ca.crt"

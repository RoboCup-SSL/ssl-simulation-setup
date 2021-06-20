#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
export COMPOSE_INTERACTIVE_NO_CLI=1

# Reload caddyfile inside running docker container
docker-compose -f "${SCRIPT_DIR}/../../docker-compose.yaml" exec -T caddy caddy reload -config /etc/caddy/Caddyfile

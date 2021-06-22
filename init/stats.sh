#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

field_name="$(cat ${SCRIPT_DIR}/../config/field_name)"

echo "$(date) $(curl -qs https://status-board.${field_name}.virtual.ssl.robocup.org/api/clients)"

#!/usr/bin/env bash

set -euo pipefail
set -x

export COMPOSE_INTERACTIVE_NO_CLI=1

cd ssl-simulation-setup || exit 1
git pull
./config/guacamole/update_guacamole.py
./config/caddy/update_caddy_passwords.sh
./config/caddy/generate_caddyfile.py
./config/caddy/update_caddy_config.sh
docker-compose -f docker-compose.yaml -f docker-compose-teams.yaml -f docker-compose-monitoring.yaml pull
docker-compose -f docker-compose.yaml -f docker-compose-teams.yaml -f docker-compose-monitoring.yaml up -d

cp ./init/referee_access_cron /etc/cron.d/

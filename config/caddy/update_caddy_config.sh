#!/usr/bin/env bash

# Reload caddyfile inside running docker container
docker-compose exec caddy caddy reload -config /etc/caddy/Caddyfile

#!/usr/bin/env bash

# Reload caddyfile inside running docker container
docker exec caddy_caddy_1 caddy reload -config /etc/caddy/Caddyfile

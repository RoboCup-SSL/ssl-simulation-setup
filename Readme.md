# Simulation Setup for virtual Small Size League Tournament

---
**Note**

This repo is still in draft mode and subject to change.

---

## Setup idea
 * A single powerful root server is used
 * Teams only access the server via Browser with Guacamole
 * A team has access to its own VNC session
 * All teams have view access to all VNC sessions, to make sure nobody is touching their system during a match
 * A team may submit a custom docker image with additional dependencies
 * The home folder is backed by a docker volume. Teams can check out their code here, and it will survive container restarts and rebuilds
 * The field can be viewed with the ssl-vision-client in the browser
 * The ssl-status-board shows the game state in the browser

TODOs:
 * How to make ssl-game-controller available?
   * Password protection via nginx?
   * Browser in VNC session and authentication via Guacamole?
 * Integrate a simulator and check if multicast, etc works
 * Check if team integration and custom team image is practical
 * Clarify integration with ssl.robocup.org or similar

## Startup

Run single local field and expose caddy on ports 80 and 443 on the host:
```shell
docker-compose up
```

Spin up a new virtual field called `field-a`
```shell
# Set field name. Defaults to field-a
export COMPOSE_PROJECT_NAME=field-a
# Start all containers
docker-compose up
```
By default, a virtual field environment does not expose any ports to avoid conflicts when spinning up multiple fields.
To get access to the virtual field, start a reverse proxy:
```shell
cd caddy
docker-compose up
```
Afterwards, visit https://localhost in your browser.

## Default credentials
In the default setup, you can log in with these credentials:
 * Guacamole
   * Admin: `guacadmin:guacadmin`
   * Team: `tigers:tigers` or `erforce:erforce`
 * Game Controller: `referee:referee`


## Shutdown and cleanup

Stop and remove all containers, networks and volumes (`-v`) for a specific field:
```shell
export COMPOSE_PROJECT_NAME=field-a
docker-compose down -v
```

Stop and remove all containers, networks and volumes (`-v`) for the reverse proxy:
```shell
cd caddy
docker-compose down -v
```

## Update

The database setup scripts are pre-generated already, but if
the guacamole version changes, the script might need to be generated again with:
```shell
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgres > init/postgres/01_initdb.sql
```

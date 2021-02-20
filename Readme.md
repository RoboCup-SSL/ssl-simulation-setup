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

Before you start anything, you need to initialize some secrets with:
```shell
./config/docker/init.sh
```
This will generate passwords and an SSH key and put them at the right places.

Now, spin up the default field `field-a`:
```shell
docker-compose up
```

You can also spin up more fields with:
```shell
# Set field name. Defaults to field-b
export COMPOSE_PROJECT_NAME=field-b
# Start all containers
docker-compose up
```
By default, a virtual field environment does not expose any ports to avoid conflicts when spinning up multiple fields.
To get access to the virtual field, start the reverse proxy:
```shell
cd caddy
docker-compose up
```
If you have more than one field, you need to add them to [caddy/docker-compose.yaml](caddy/docker-compose.yaml) manually.
If you are running locally, you might want to add the local CA from caddy to your system with:
```shell
# Note: Have a look at this script for more details
./caddy/install_local_CA.sh
```
Afterwards, visit https://localhost in your browser.

To get access, you need to do some more configuration.
First, update the files `fields`, `teams` and `root_domain` in [./config](config) to your needs.

Guacamole (the VNC frontend) needs to be initialized on first use:
```shell
./config/guacamole/update_guacamole.py
```
The script will generate new passwords for all teams and the admin user under [config/passwords](./config/passwords).

Caddy is configured to serve only the default field `field-a` by default. To add additional fields and to add
custom credentials for the game-controller, run:
```shell
# Convert the team passwords to caddy-compatible password hashes
./config/caddy/update_caddy_passwords.sh
# Generate the new Caddyfile
./config/caddy/generate_caddyfile.py
# Load the new Caddyfile into the running Caddy server
./config/caddy/update_caddy_config.sh
```

## Usage notes

- In Guacamole, you can press Ctrl + Shift + Alt to open a menu where you can copy files from/to the VNC session.

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

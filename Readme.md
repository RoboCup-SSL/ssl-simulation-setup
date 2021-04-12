# Simulation Setup for virtual Small Size League Tournament

This repository contains the configuration for a virtual Small Size League tournament
with multiple fields and all components that are required.

## Setup idea
 * A single powerful root server is used per field or for multiple fields
 * Teams only access the server via Browser with Guacamole
 * A team has access to its own VNC session (a virtual desktop)
 * All teams have view access to all VNC sessions, to make sure nobody is touching their system during a match
 * A team may submit a custom docker image with additional dependencies
 * The home folder is backed by a docker volume. Teams can check out their code here, and it will survive container restarts and rebuilds
 * The field can be viewed with the ssl-vision-client in the browser
 * The ssl-status-board shows the game state in the browser
 * The ssl-game-controller is protected with user/password. Only the refereeing team and the admin is activated per match.
 * The [ssl-simulation-controller](https://github.com/RoboCup-SSL/ssl-simulation-controller) manages manual ball and robot placement and simulation configuration

## Requirements

Following software is required, which should be available on all major operating systems:

* Docker and Docker-Compose
* Bash
* Python 3

## Preparations for teams

As a team, you need to make sure that your software can run on Ubuntu 20.04 and without root permissions.
If you require a GPU or have other specific requirements, ask the technical committee if it will be possible.

Each team has its own docker container including a simple desktop environment.
If you need additional libraries to run and/or build your software, create a custom docker image based on [src/ubuntu-vnc](src/ubuntu-vnc). Use [src/ubuntu-vnc-java](src/ubuntu-vnc-java) as a template. Then submit a pull-request with the new docker image.
It is possible to copy files into the container, so you can also build your software locally and only copy the binaries over.

Your container will have a volume mounted to the home folder. The volume will be used for all fields, while there will be individual containers per field. You do not need to worry about changing any network addresses or ports, they will always be the same.
You should be able to handle multiple network interfaces, though.

To integrate your own container, add a new service to [docker-compose.yaml](docker-compose.yaml). Take the tigers or erforce service as a template.
Also, add your team name to [config/teams](./config/teams). It should be all-lower-case without any special characters.

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
custom credentials for the game-controller (default is referee:referee), run:
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
- You can also drag&drop files into the browser tab to copy files into the home folder
- The home folder is backed by a volume, so all files in the home folder will survive container rebuilds

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

## Run on AWS
The full setup can be deployed to AWS with terraform:
```shell
cd terraform
terraform init
terraform apply
```
Make sure to make yourself familiar with AWS and terraform, before doing this.

## Update

The database setup scripts are pre-generated already, but if
the guacamole version changes, the script might need to be generated again with:
```shell
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgres > init/postgres/01_initdb.sql
```

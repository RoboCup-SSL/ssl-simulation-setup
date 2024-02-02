# Simulation Setup for virtual Small Size League Tournament

This repository contains the configuration for a virtual Small Size League tournament
with multiple fields and all components that are required.

## Setup idea
 * A single powerful root server is used per field
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

To integrate your own container, add a new service to [docker-compose-teams.yaml](docker-compose-teams.yaml). Take the tigers or erforce service as a template.
Also, add your team name to [config/teams](./config/teams). It should be all-lower-case without any special characters.


## Setup

If you want to use a remote server, change the root domain and field name first in [./config/root_domain](./config/root_domain) and [./config/field_name](./config/field_name). Else, the defaults are fine.

Before you start anything, you need to initialize some secrets with:
```shell
./config/docker/init.sh
```
This will generate passwords and an SSH key and put them at the right places.

Next, generate the initial Caddyfile for the webserver:
```shell
./config/caddy/generate_caddyfile.py
```

Now, you can spin up the field:
```shell
# Start all containers and keep showing the log in the foreground (ctrl+c will stop everything again)
docker compose up
# Or alternatively run all containers in the background:
docker compose up -d
```

Next, setup Guacamole and caddy:
```shell
# Sets up the running Guacamole (VNC) server. Will also generate team passwords.
./config/guacamole/update_guacamole.py
# Convert all passwords into a caddy format for the game-controller
./config/caddy/update_caddy_passwords.sh
# Regenerate the Caddyfile with the newly created passwords
./config/caddy/generate_caddyfile.py
# Reload the running caddy webserver
./config/caddy/update_caddy_config.sh
```

Finally, spin up the team containers that you need:
```shell
# Start team containers (individually or all together)
docker compose -f docker-compose-teams.yaml up [team-container]
```


# Access

You can access the field through your browser now.
The URL is https://localhost or whatever you chose as the root domain.

If you are running locally, you might want to add the local CA from caddy to your system with:
```shell
# Note: Have a look at this script for more details
./caddy/install_local_CA.sh
```

All credentials were generated to [./config/passwords](./config/passwords).


# Usage notes

- In Guacamole, you can press Ctrl + Shift + Alt to open a menu where you can copy files from/to the VNC session.
- You can also drag&drop files into the browser tab to copy files into the home folder
- The home folder is backed by a volume, so all files in the home folder will survive container rebuilds
- To paste text into the terminal, use Shift+Insert


# Shutdown and cleanup

Stop and remove all containers, networks and volumes (`-v`) for a specific field:
```shell
docker compose down -v
```


# Run on AWS
The full setup can be deployed to AWS with terraform:
```shell
cd terraform
terraform init
terraform apply
```
Make sure to make yourself familiar with AWS and terraform, before doing this.

# Update

The database setup scripts are pre-generated already, but if
the guacamole version changes, the script might need to be generated again with:
```shell
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgres > init/postgres/01_initdb.sql
```

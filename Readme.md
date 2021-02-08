# Simulation Setup for virtual Small Size League Tournament

---
**Note**

This repo is still in draft mode and subject to change.

---

## Startup

Start all containers:
```shell
docker-compose up --build
```
Afterwards, guacamole should be available at: http://localhost:8080/guacamole
Default admin username and password is `guacadmin`.
Two dummy teams are available: `tigers` and `erforce`, password = username.

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

## Shutdown and cleanup

Stop and remove all containers, networks and volumes (`-v`)
```shell
docker-compose down -v
```

## Update

The database setup scripts are pre-generated already, but if
the guacamole version changes, the script might need to be generated again with:
```shell
docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --postgres > init/postgres/01_initdb.sql
```


Run single local field and expose caddy on ports 80 and 443 on the host:
```shell
docker-compose up
```

Spin up a new virtual field called `field-a`:
```shell
export FIELD_NAME=field-a
docker-compose -p ${FIELD_NAME} --env-file field.env up
```

Start a reverse proxy that redirects to the individual fields:
```shell
docker-compose -p caddy -f caddy.docker-compose.yaml up
```


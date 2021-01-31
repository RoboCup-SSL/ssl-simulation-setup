# Simulation Setup for virtual Small Size League Tournament

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

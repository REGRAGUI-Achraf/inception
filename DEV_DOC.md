# Developer Documentation

## Goal

This document explains how to set up, build, run, and maintain the Inception project from a development point of view.

The project uses Docker and Docker Compose to create a multi-container web hosting stack with isolated services.

## Prerequisites

Before starting, make sure the following tools are installed:

- Docker
- Docker Compose
- `make`
- A Unix-like environment

## Project structure

The repository is organized as follows:

- `Makefile`: top-level shortcuts for build, cleanup, and rebuild commands
- `srcs/docker-compose.yml`: service definitions, networks, ports, secrets, and volumes
- `srcs/requirements/`: Dockerfiles and configuration for each service
- `secrets/`: plaintext secret files mounted into containers as Docker secrets

## Configuration files and secrets

The project uses a `.env` file in `srcs/` for non-sensitive configuration values such as:

- `DOMAIN_NAME`
- `MYSQL_DATABASE`
- `MYSQL_USER`
- `FTP_USER`
- `FTP_PASSWORD`

Sensitive values are stored in the `secrets/` directory and mounted as Docker secrets:

- `secrets/db_password.txt`
- `secrets/db_root_password.txt`
- `secrets/credentials.txt`
- `secrets/ftp_password.txt`

These files are ignored by Git and should not be committed.

## Build and launch

The easiest way to build and start the stack is:

```bash
make
```

This command creates the host data directories and runs:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

To rebuild everything from scratch:

```bash
make re
```

## Container management commands

The Makefile provides the main lifecycle commands:

```bash
make down
```

Stops the running containers.

```bash
make clean
```

Stops the stack and removes containers, volumes, and images.

```bash
make fclean
```

Performs `make clean` and also removes the host data directories under `~/data`.

You can also use Docker Compose directly when needed:

```bash
docker compose -f srcs/docker-compose.yml up -d --build
```

```bash
docker compose -f srcs/docker-compose.yml down
```

```bash
docker compose -f srcs/docker-compose.yml down --volumes --rmi all
```

## Data persistence

The project uses bind-mounted host directories for persistent data:

- MariaDB data: `/home/user/data/mariadb`
- WordPress data: `/home/user/data/wordpress`

These paths are declared as Docker volume driver options in `srcs/docker-compose.yml`. Because they are mounted from the host, the data survives container recreation and image rebuilds.

## Services and networking

The services run on a dedicated Docker bridge network named `inception`.

Published services include:

- `nginx` on port `443`
- `ftp` on ports `21` and `21100-21110`
- `static-site` on port `8080`
- `netdata` on port `19999`

Other services are only reachable inside the Docker network by service name.

## Useful verification commands

Check container status:

```bash
docker ps
```

Check service logs:

```bash
docker logs srcs-mariadb-1
```

```bash
docker logs srcs-wordpress-1
```

```bash
docker logs srcs-nginx-1
```

```bash
docker logs srcs-adminer-1
```

```bash
docker logs srcs-ftp-1
```

```bash
docker logs srcs-netdata-1
```

Test the exposed endpoints:

```bash
curl -k -I https://aregragu.42.fr
curl -k -I https://aregragu.42.fr/adminer
curl -I http://aregragu.42.fr:19999/
```

## Setup from scratch

A developer starting from a fresh clone should:

1. Install Docker, Docker Compose, and `make`.
2. Ensure the `.env` file exists in `srcs/` with the required non-sensitive variables.
3. Ensure the required secret files exist in `secrets/`.
4. Run `make` to create the host data directories and build the stack.
5. Use `make re` whenever a clean rebuild is required.

## Notes

- Services are designed to be rebuilt independently, but `make re` is the safest full reset.
- If you change any service Dockerfile or configuration file, rebuild that service with Docker Compose or rerun `make`.
- The project is intended to be reproducible, so avoid storing credentials inside Dockerfiles or Compose files.

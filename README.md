*This project has been created as part of the 42 curriculum by user.*

# Inception

## Description

Inception is a Docker-based infrastructure project from the 42 curriculum. The goal is to build a small but realistic web hosting stack using isolated containers, one service per container, all connected through a dedicated Docker network.

This repository provides a complete WordPress stack with MariaDB, Nginx, and several bonus services. The project focuses on container orchestration, secure configuration, data persistence, and service-to-service communication. It also demonstrates how Docker can replace a traditional virtual machine approach with a lighter and more reproducible architecture.

### Included services

- MariaDB for the WordPress database
- WordPress with PHP-FPM
- Nginx as the HTTPS reverse proxy
- Redis as a bonus caching service
- FTP with passive mode support
- Adminer for database administration
- Netdata for monitoring
- A static site bonus service

## Project Design Choices

### Docker architecture

The stack is split into independent services, each running in its own container. This keeps the system modular, easier to rebuild, and simpler to debug. Containers communicate through the `inception` bridge network, while persistent data is stored on the host using bind-mounted volumes.

### Virtual Machines vs Docker

- Virtual Machines emulate a full operating system, which provides strong isolation but uses more resources.
- Docker shares the host kernel, so containers start faster, use less memory, and are easier to recreate.
- For this project, Docker is the better fit because the goal is reproducible infrastructure with a small footprint, not full guest OS isolation.

### Secrets vs Environment Variables

- Environment variables are convenient, but they are visible in process lists, container metadata, and sometimes logs.
- Docker secrets are mounted as files and are better suited for passwords and sensitive credentials.
- In this project, secrets are used for database credentials, WordPress passwords, and FTP authentication to reduce accidental exposure.

### Docker Network vs Host Network

- A Docker bridge network isolates services from the host and from unrelated containers.
- The host network removes that isolation and exposes services directly on the host stack.
- This project uses a dedicated bridge network so that services can communicate by container name while remaining isolated from the host networking layer.

### Docker Volumes vs Bind Mounts

- Docker volumes are managed by Docker and are useful for persistent application data.
- Bind mounts map a host path directly into the container and make data easier to inspect and reset during development.
- This project uses bind-mounted host directories for MariaDB and WordPress data to make rebuilding and cleanup straightforward.

## Instructions

### Prerequisites

- Docker
- Docker Compose
- A Unix-like environment with `make`

### Build and run

From the root of the repository:

```bash
make
```

This will create the required host data directories and launch the full stack with Docker Compose.

### Rebuild from scratch

```bash
make re
```

### Stop the stack

```bash
make down
```

### Remove containers, images, and volumes

```bash
make clean
```

### Full cleanup of data directories

```bash
make fclean
```

## Resources

### Technical references

- Docker documentation: https://docs.docker.com/
- Docker Compose documentation: https://docs.docker.com/compose/
- Nginx documentation: https://nginx.org/en/docs/
- WordPress documentation: https://wordpress.org/documentation/
- MariaDB documentation: https://mariadb.com/kb/en/documentation/
- Adminer documentation: https://www.adminer.org/
- Redis documentation: https://redis.io/docs/
- vsftpd documentation: https://security.appspot.com/vsftpd.html
- Netdata documentation: https://learn.netdata.cloud/

### AI usage

AI was used as a coding and documentation assistant to help with:

- drafting and polishing this README in English
- explaining the Docker design choices and required comparisons
- validating command sequences and project instructions
- troubleshooting container configuration issues during development

AI was not used as a substitute for the project requirements: the actual implementation, service wiring, and final configuration choices were verified against the repository and the Docker setup.

## Additional Notes

- The project uses Docker secrets for passwords instead of hardcoding them in the compose file.
- Each major service runs in its own container to keep the stack modular and predictable.
- The `inception` bridge network allows containers to resolve each other by service name.

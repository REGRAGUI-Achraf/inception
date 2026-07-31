# User Documentation

## What this project provides

This project runs a small Docker-based web stack with the following services:

- `nginx`: HTTPS reverse proxy and public entry point
- `wordpress`: the website and PHP application
- `mariadb`: database backend used by WordPress
- `adminer`: database administration interface
- `ftp`: passive FTP access to the WordPress files
- `redis`: cache service used by the stack
- `netdata`: monitoring dashboard
- `static-site`: bonus static website service

## How to start and stop the project

From the root of the repository:

```bash
make
```

This creates the required host data directories and starts the whole stack.

To stop the containers:

```bash
make down
```

To remove containers, images, and volumes:

```bash
make clean
```

To fully reset the persistent host data and rebuild everything:

```bash
make re
```

## How to access the services

### Main website

Open the website in a browser:

- `https://aregragu.42.fr`

The browser may show a certificate warning because the project uses a self-signed certificate.

### Administration panel

Adminer is available at:

- `https://aregragu.42.fr/adminer`

Use the MariaDB credentials described below.

### Monitoring dashboard

Netdata is available at:

- `http://aregragu.42.fr:19999`

### Static site bonus

The static site is exposed on:

- `http://aregragu.42.fr:8080`

### FTP bonus

FTP is available on:

- host: `aregragu.42.fr`
- port: `21`
- passive ports: `21100-21110`

## Credentials and secrets

The project stores sensitive data in the `secrets/` directory. These files are ignored by Git and are mounted as Docker secrets inside the containers.

### WordPress login credentials

- Admin user: `superachraf`
- Admin password: read from `secrets/credentials.txt`
- Regular user: `achraf`
- Regular user password: read from `secrets/credentials.txt`

### Database credentials

- MariaDB normal user: `wp_user`
- MariaDB password: read from `secrets/db_password.txt`
- MariaDB root password: read from `secrets/db_root_password.txt`

### FTP credentials

- FTP user: `achraf_ftp`
- FTP password: read from `secrets/ftp_password.txt`

### Where to find the secret files

- `secrets/credentials.txt`
- `secrets/db_password.txt`
- `secrets/db_root_password.txt`
- `secrets/ftp_password.txt`

If you need to inspect the mounted secret inside a container, you can use a command such as:

```bash
docker exec -it srcs-wordpress-1 cat /run/secrets/credentials
```

## How to check that services are running correctly

Use Docker to confirm that the containers are up:

```bash
docker ps
```

Useful health checks:

```bash
docker logs srcs-nginx-1
```

```bash
docker logs srcs-wordpress-1
```

```bash
docker logs srcs-mariadb-1
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

You can also test the public endpoints directly:

```bash
curl -k -I https://aregragu.42.fr
curl -k -I https://aregragu.42.fr/adminer
curl -I http://aregragu.42.fr:19999/
```

## Notes

- The services communicate through the `inception` Docker bridge network.
- WordPress and MariaDB data persist on the host even after container restarts.
- Use `make re` if you want a full clean rebuild of the project.

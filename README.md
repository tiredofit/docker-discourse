# hub.docker.com/tiredofit/discourse

# Introduction

Dockerfile to build a [Discourse](https://www.discourse.org) container image.

* This Container uses Debian as a base which includes [s6 
overlay](https://github.com/just-containers/s6-overlay) enabled for PID 1 Init capabilities, [zabbix-agent](https://zabbix.org) based on TRUNK compiled for individual container monitoring, Cron also installed along with other tools (bash,curl, less, logrotate, nano, updated postgres-client, vim) for easier management.
* Unlike the official Discourse image, this is meant to be self contained without requiring a base image or use the `launcher`
* Nginx performance report removed, SQL Query, Voting and Solved Plugins installed.

[Changelog](CHANGELOG.md)

# Authors

- [Dave Conroy](http://github/tiredofit/)

# Table of Contents

- [Introduction](#introduction)
    - [Changelog](CHANGELOG.md)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
    - [Database](#database)
    - [Data Volumes](#data-volumes)
    - [Environment Variables](#environmentvariables)   
    - [Networking](#networking)
- [Maintenance](#maintenance)
    - [Shell Access](#shell-access)
   - [References](#references)

# Prerequisites

This image assumes that you are using a reverse proxy such as [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) and optionally the [Let's Encrypt Proxy Companion @ https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) in order to serve your pages. However, it will run just fine on it's own if you map appropriate ports.

You will also require an external Redis container, along with an external Postgres DB container, as well an an external SMTP server.



# Installation

Automated builds of the image are available on [Registry](https://hub.docker.com/tiredofit/discourse) and is the recommended method of installation.


```bash
docker pull hub.docker.com/tiredofit/discourse:(imagetag)
```

The following image tags are available:

* `latest` - Most recent stable release of PHP w/Debian Jessie

# Quick Start

* The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [docker-compose.yml](examples/docker-compose.yml) that can be modified for development or production use.

* Set various [environment variables](#environment-variables) to understand the capabilities of this image.
* Map [persistent storage](#data-volumes) for access to configuration and data files for backup.

# Configuration

### Data-Volumes

The container operates heavily from the `/app` folder, however there are a few folders that should be persistently mapped to ensure data persistence. The following directories are used for configuration and can be mapped for persistent storage.

| Directory | Description |
|-----------|-------------|
| `/app/log` | Logfiles |
| `/app/public/uploads` | Uploads Directory |
| `/app/public/backups` | Backups Directory |
      
### Database

Edit the environment variables to point to a working Postgres Server with the appropriate credentials, and create a database with the name `discourse` and assign appropriate permissions. The database will automatically populate and also upgrade upon startup if the discourse version changes with new releases of this image.

### Environment Variables

Along with the Environment Variables from the Base image, below is the complete list of available options 
that can be used to customize your installation.


| Parameter | Description |
|-----------|-------------|
| `ZABBIX_HOSTNAME` | Hostname of container to report to Zabbix | 
| `DISCOURSE_DB_HOST` | Your Postgres DB Host e.g. `discuss-db` |
| `DISCOURSE_DB_PASSWORD` | The password for the discourse db e.g. `password` |
| `DISCOURSE_REDIS_HOST` | External Redis Host e.g. `discuss-redis` |
| `DISCOURSE_HOSTNAME`= | The URL of your Public Discourse Installation e.g. `discourse.example.org` |
| `DISCOURSE_SMTP_ADDRESS` | The hostname of your external SMTP server e.g. `postfix-relay` |
| `DISCOURSE_SMTP_PORT` | The port that SMTP listens on e.g. `25` |
| `DISCOURSE_SMTP_USER_NAME` | Optional - Username for SMTP Authentication e.g. `smtpuser` |
| `DISCOURSE_SMTP_PASSWORD` | Optional - Password for SMTP Authentication e.g. `password` |
| `DISCOURSE_DEVELOPER_EMAILS` | The administrative email which the first account will be created with e.g. `admin@example.com` |




### Networking

The following ports are exposed.

| Port      | Description |
|-----------|-------------|
| `3000` 		| Rails		    |

# Maintenance
#### Shell Access

For debugging and maintenance purposes you may want access the containers shell. 

```bash
docker exec -it (whatever your container name is e.g. discourse) bash
```

# References

* https://www.discourse.org


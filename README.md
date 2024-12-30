# github.com/tiredofit/docker-discourse

[![GitHub release](https://img.shields.io/github/v/tag/tiredofit/docker-discourse?style=flat-square)](https://github.com/tiredofit/docker-discourse/releases/latest)
[![Build Status](https://img.shields.io/github/actions/workflow/status/tiredofit/docker-discourse/main.yml?branch=main&style=flat-square)](https://github.com/tiredofit/docker-discourse/actions)
[![Docker Stars](https://img.shields.io/docker/stars/tiredofit/discourse.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/tiredofit/discourse/)
[![Docker Pulls](https://img.shields.io/docker/pulls/tiredofit/discourse.svg?style=flat-square&logo=docker)](https://hub.docker.com/r/tiredofit/discourse/)
[![Become a sponsor](https://img.shields.io/badge/sponsor-tiredofit-181717.svg?logo=github&style=flat-square)](https://github.com/sponsors/tiredofit)
[![Paypal Donate](https://img.shields.io/badge/donate-paypal-00457c.svg?logo=paypal&style=flat-square)](https://www.paypal.me/tiredofit)

* * *
## About

This will build a Docker Image for [Discourse](https://www.discourse.org/) - A web based discussion forum.

* Unlike the official Discourse image, this is meant to be self contained without requiring a base image or use the `launcher`
* Additional Plugins installed
* Flexible Volatile Storage


[Changelog](CHANGELOG.md)

## Maintainer

- [Dave Conroy](http://github/tiredofit/)

## Table of Contents

- [About](#about)
- [Maintainer](#maintainer)
- [Table of Contents](#table-of-contents)
- [Prerequisites and Assumptions](#prerequisites-and-assumptions)
- [Installation](#installation)
  - [Build from Source](#build-from-source)
  - [Prebuilt Images](#prebuilt-images)
- [Configuration](#configuration)
  - [Quick Start](#quick-start)
  - [Persistent Storage](#persistent-storage)
    - [Base Images used](#base-images-used)
    - [Container Options](#container-options)
    - [Admin Options](#admin-options)
    - [Log Options](#log-options)
    - [Performance Options](#performance-options)
    - [Database Options](#database-options)
      - [Postgresql](#postgresql)
      - [Redis](#redis)
    - [SMTP Options](#smtp-options)
    - [Plugins](#plugins)
  - [Networking](#networking)
- [Maintenance](#maintenance)
  - [Shell Access](#shell-access)
- [Support](#support)
  - [Usage](#usage)
  - [Bugfixes](#bugfixes)
  - [Feature Requests](#feature-requests)
  - [Updates](#updates)
- [License](#license)

## Prerequisites and Assumptions
*  Assumes you are using some sort of SSL terminating reverse proxy such as:
   *  [Traefik](https://github.com/tiredofit/docker-traefik)
   *  [Nginx](https://github.com/jc21/nginx-proxy-manager)
   *  [Caddy](https://github.com/caddyserver/caddy)
*  Requires access to a Postgres Server
*  Requires access to a Redis Server

## Installation

### Build from Source
Clone this repository and build the image with `docker build -t (imagename) .`

### Prebuilt Images
Builds of the image are available on [Docker Hub](https://hub.docker.com/r/tiredofit/discourse)

```bash
docker pull docker.io/tiredofit/discourse:(imagetag)
```

Builds of the image are also available on the [Github Container Registry](https://github.com/tiredofit/docker-discourse/pkgs/container/docker-discourse)

```
docker pull ghcr.io/tiredofit/docker-discourse:(imagetag)
```

The following image tags are available along with their tagged release based on what's written in the [Changelog](CHANGELOG.md):

| Container OS | Tag       |
| ------------ | --------- |
| Debian       | `:latest` |

## Configuration

### Quick Start

- The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [docker-compose.yml](examples/compose.yml) that can be modified for development or production use.

- Set various [environment variables](#environment-variables) to understand the capabilities of this image.
- Map [persistent storage](#data-volumes) for access to configuration and data files for backup.
- Make [networking ports](#networking) available for public access if necessary

**The first boot can take from 2 minutes - 5 minutes depending on your CPU to setup the proper schemas and precompile assets**


### Persistent Storage

The container operates heavily from the `/app` folder, however there are a few folders that should be persistently mapped to ensure data persistence. The following directories are used for configuration and can be mapped for persistent storage.

| Directory       | Description       |
| --------------- | ----------------- |
| `/data/logs`    | Logfiles          |
| `/data/uploads` | Uploads Directory |
| `/data/backups` | Backups Directory |
| `/data/plugins` | Plugins Driectory |

#### Base Images used

This image relies on a [Debian Linux](https://hub.docker.com/r/tiredofit/debian) base image that relies on an [init system](https://github.com/just-containers/s6-overlay) for added capabilities. Outgoing SMTP capabilities are handlded via `msmtp`. Individual container performance monitoring is performed by [zabbix-agent](https://zabbix.org). Additional tools include: `bash`,`curl`,`less`,`logrotate`,`nano`.

Be sure to view the following repositories to understand all the customizable options:

| Image                                                  | Description                            |
| ------------------------------------------------------ | -------------------------------------- |
| [OS Base](https://github.com/tiredofit/docker-debian/) | Customized Image based on Debian Linux |
| [Nginx](https://github.com/tiredofit/docker-nginx/)    | Nginx webserver                        |


#### Container Options
| Parameter                  | Description                                                        | Default                |
| -------------------------- | ------------------------------------------------------------------ | ---------------------- |
| `BACKUP_PATH`              | Place to store in app backups                                      | `{DATA_PATH}/backups/` |
| `DELIVER_SECURE_ASSETS`    | Enable serving of HTTPS assets                                     | `FALSE`                |
| `ENABLE_DB_MIGRATE`        | Enable DB Migrations on startup                                    | `TRUE`                 |
| `ENABLE_MINIPROFILER`      | Enable Mini Profiler                                               | `FALSE`                |
| `ENABLE_PRECOMPILE_ASSETS` | Enable Precompiling Assets on statup                               | `TRUE`                 |
| `SETUP_MODE`               | Automatically generate config based on these environment variables | `AUTO`                 |
| `ENABLE_CORS`              | Enable CORS                                                        | `FALSE`                |
| `CORS_ORIGIN`              | CORS Origin                                                        | ``                     |
| `UPLOADS_PATH`             | Path to store Uploads                                              | `{DATA_PATH}/uploads/` |

#### Admin Options

>> Only used on first boot

| Parameter     | Description                                 | Default               |
| ------------- | ------------------------------------------- | --------------------- |
| `ADMIN_USER`  | Username for admin                          | `admin`               |
| `ADMIN_EMAIL` | Admin email address                         | `admin@example.com`   |
| `ADMIN_PASS`  | Admin password - Must be over 10 characters | `tiredofit-discourse` |
| `ADMIN_NAME`  | Admin Name (First and Last)                 | `Admin User`          |

#### Log Options
| Parameter                | Description            | Default             |
| ------------------------ | ---------------------- | ------------------- |
| `LOG_FILE`               | Discourse Log File     | `discourse.log`     |
| `LOG_LEVEL`              | Discourse Log Level    | `info`              |
| `LOG_PATH`               | Path to store logfiles | `{DATA_PATH}/logs/` |
| `UNICORN_LOG_FILE`       | Unicorn Log            | `unicorn.log`       |
| `UNICORN_LOG_ERROR_FILE` | Unicorn Error Log      | `unicorn_error.log` |
| `SIDEKIQ_LOG_FILE`       | SideKiq Log            | `sidekiq.log`       |

#### Performance Options
| Parameter         | Description         | Default |
| ----------------- | ------------------- | ------- |
| `UNICORN_WORKERS` | How many Workers    | `8`     |
| `SIDEKIQ_THREADS` | Sidekiq Concurrency | `25`    |


#### Database Options

##### Postgresql
| Parameter            | Description                                   | Default |
| -------------------- | --------------------------------------------- | ------- |
| `DB_POOL`            | How many Database connections                 | `8`     |
| `DB_PORT`            | Database Port                                 | `5432`  |
| `DB_TIMEOUT`         | Timeout for established connection in seconds | `5000`  |
| `DB_TIMEOUT_CONNECT` | Connection Timeout in Seconds                 | `5`     |
| `DB_USER`            | Username of Database                          |         |
| `DB_NAME`            | Database name                                 |         |
| `DB_PASS`            | Database Password                             |         |
| `DB_HOST`            | Hostname of Database Server                   |         |

##### Redis
| Parameter                    | Description                                 | Default |
| ---------------------------- | ------------------------------------------- | ------- |
| `REDIS_DB`                   | Redis Database Number                       | `0`     |
| `REDIS_ENABLE_TLS`           | Enable TLS when communication to REDIS_HOST | `FALSE` |
| `REDIS_PORT`                 | Redis Host Listening Port                   | `6379`  |
| `REDIS_SKIP_CLIENT_COMMANDS` | Skip client commands if unsupported         | `FALSE` |

#### SMTP Options
| Parameter             | Description                              | Default         |
| --------------------- | ---------------------------------------- | --------------- |
| `SMTP_AUTHENTICATION` | SMTP Authentication type `plain` `login` | `plain`         |
| `SMTP_DOMAIN`         | HELO Domain for remote SMTP Host         | `example.com`   |
| `SMTP_HOST`           | SMTP Hostname                            | `postfix-relay` |
| `SMTP_USER`           | SMTP Username                            |                 |
| `SMTP_PASS`           | SMTP Username                            |                 |
| `SMTP_PORT`           | SMTP Port                                | `25`            |
| `SMTP_START_TLS`      | Enable STARTTLS on connection            | `TRUE`          |
| `SMTP_TLS_FORCE`      | Force TLS on connection                  | `FALSE`         |
| `SMTP_TLS_VERIFY`     | TLS Certificate verification             | `none`          |

#### Plugins
| Parameter                          | Description                   | Default                |
| ---------------------------------- | ----------------------------- | ---------------------- |
| `PLUGIN_PATH`                      | Path where plugins are stored | `{DATA_PATH}/plugins/` |
| `PLUGIN_ENABLE_AUTOMATION`         |                               | `FALSE`                |
| `PLUGIN_ENABLE_ASSIGN`             |                               | `FALSE`                |
| `PLUGIN_ENABLE_CHAT_INTEGRATION`   |                               | `FALSE`                |
| `PLUGIN_ENABLE_CHECKLIST`          |                               | `FALSE`                |
| `PLUGIN_ENABLE_DETAILS`            |                               | `TRUE`                 |
| `PLUGIN_ENABLE_EVENTS`             |                               | `FALSE`                |
| `PLUGIN_ENABLE_FOOTNOTES`          |                               | `FALSE`                |
| `PLUGIN_ENABLE_FORMATTING_TOOLBAR` |                               | `FALSE`                |
| `PLUGIN_ENABLE_LAZY_VIDEOS`        |                               | `TRUE`                 |
| `PLUGIN_ENABLE_LOCAL_DATES`        |                               | `TRUE`                 |
| `PLUGIN_ENABLE_MERMAID`            |                               | `TRUE`                 |
| `PLUGIN_ENABLE_NARRATIVE_BOT`      |                               | `TRUE`                 |
| `PLUGIN_ENABLE_POLLS`              |                               | `TRUE`                 |
| `PLUGIN_ENABLE_POST_VOTING`        |                               | `FALSE`                |
| `PLUGIN_ENABLE_PRESENCE`           |                               | `TRUE`                 |
| `PLUGIN_ENABLE_PUSH_NOTIFICATIONS` |                               | `FALSE`                |
| `PLUGIN_ENABLE_SAME_ORIGIN`        |                               | `FALSE`                |
| `PLUGIN_ENABLE_SOLVED`             |                               | `FALSE`                |
| `PLUGIN_ENABLE_SPOILER_ALERT`      |                               | `FALSE`                |
| `PLUGIN_ENABLE_STYLEGUIDE`         |                               | `TRUE`                 |
| `PLUGIN_ENABLE_VOTING`             |                               | `FALSE`                |

### Networking

The following ports are exposed.

| Port   | Description |
| ------ | ----------- |
| `3000` | Unicorn     |

* * *
## Maintenance

### Shell Access

For debugging and maintenance purposes you may want access the containers shell.

``bash
docker exec -it (whatever your container name is) bash
``

Try using the command `rake --tasks`

## Support

These images were built to serve a specific need in a production environment and gradually have had more functionality added based on requests from the community.
### Usage
- The [Discussions board](../../discussions) is a great place for working with the community on tips and tricks of using this image.
- [Sponsor me](https://tiredofit.ca/sponsor) for personalized support
### Bugfixes
- Please, submit a [Bug Report](issues/new) if something isn't working as expected. I'll do my best to issue a fix in short order.

### Feature Requests
- Feel free to submit a feature request, however there is no guarantee that it will be added, or at what timeline.
- [Sponsor me](https://tiredofit.ca/sponsor) regarding development of features.

### Updates
- Best effort to track upstream changes, More priority if I am actively using the image in a production environment.
- [Sponsor me](https://tiredofit.ca/sponsor) for up to date releases.

## License
MIT. See [LICENSE](LICENSE) for more details.
# References

* https://www.discourse.org



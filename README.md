# docker-code-server

[![GitHub Release](https://img.shields.io/github/v/release/finleyfamily/docker-code-server?logo=github&color=2496ED)](https://github.com/finleyfamily/docker-code-server/releases)
[![pre-commit.ci status](https://results.pre-commit.ci/badge/github/finleyfamily/docker-code-server/master.svg)](https://results.pre-commit.ci/latest/github/finleyfamily/docker-code-server/master)
[![renovate](https://img.shields.io/badge/renovate-enabled-brightgreen?logo=renovate&logoColor=143C8C)](https://developer.mend.io/github/finleyfamily/docker-code-server)
[![license][license-shield]](./LICENSE)

Debian Linux based [code-server] image.

**Table Of Contents** <!-- markdownlint-disable-line MD036 -->

<!-- mdformat-toc start --slug=github --no-anchors --maxlevel=6 --minlevel=2 -->

- [Usage](#usage)
- [Features](#features)
- [Configuration](#configuration)
  - [Environment Variables](#environment-variables)
  - [Volumes](#volumes)
    - [`/config`](#config)
    - [`/var/run/docker.sock`](#varrundockersock)

<!-- mdformat-toc end -->

______________________________________________________________________

## Usage

```yaml
services:
  code-server:
    image: ghcr.io/finleyfamily/docker-code-server:latest
    ports:
      - 9022:22
      - 9080:80
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - $PWD/config:/config
```

> [!TIP]
> See [`docker-compose.yml`](./docker-compose.yml) for a full usage example.

______________________________________________________________________

## Features

This image has all the features of [`finleyfamily/docker-base-debian`] plus:

- SSH client & server
- Docker CLI
- [code-server] exposed on port 80

______________________________________________________________________

## Configuration

Configuration is done through a combination of environment variables and volumes/bind mounts.

> [!NOTE]
> Refer to the documentation of the [`finleyfamily/docker-base-debian`] image for additional configuration info.

### Environment Variables

| Variable            | Default              | Description                                                                                  |
| ------------------- | -------------------- | -------------------------------------------------------------------------------------------- |
| `DEFAULT_WORKSPACE` | `/config/workspaces` | The default workspace (directory or `*.code-workspace` file) that will be opened by default. |
| `GITHUB_TOKEN`      |                      | GitHub Personal Access Token that will be used by \[`code-server`\].                         |

### Volumes

#### `/config`

The `/config` volume is used to store the majority of persistent [code-server] & SSH data.

| Path within `/config`      | Description                                                                                                         |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `.code-server/Machine/`    | machine level [code-server]/vscode setting storage                                                                  |
| `.code-server/User/`       | user level [code-server]/vscode setting storage                                                                     |
| `.code-server-extensions/` | persistant storage for [code-server] extensions                                                                     |
| `.ssh/`                    | symlinked to `/root/.ssh/`                                                                                          |
| `workspaces/`              | storage for `.code-workspace` files                                                                                 |
| `.zsh_history`             | persistent ZSH history (created on start)                                                                           |
| `config.yaml`              | [code-server] config file (created from [config.yaml](rootfs/root/.config/code-server/config.yaml) if not provided) |
| `ssh_host_ed25519_key`     | persistent host key generated before starting the SSH server                                                        |
| `ssh_host_rsa_key`         | persistent RSA host key generated before starting the SSH server                                                    |

#### `/var/run/docker.sock`

Binds the Docker socket of the host system to the container.

> [!TIP]
> Bind mount your `.docker/config.json` file to customize authentication, CLI output format, etc.
>
> ```yaml
> services:
>   service-name:
>     volumes:
>       - source: $HOME/.docker/config.json
>         target: /root/.docker/config.json
>         type: bind
> ```

[code-server]: https://github.com/coder/code-server
[license-shield]: https://img.shields.io/github/license/finleyfamily/docker-code-server.svg
[`finleyfamily/docker-base-debian`]: https://github.com/finleyfamily/docker-base-debian

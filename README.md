# vsftpd-conf

[![GitHub Repo](https://img.shields.io/badge/GitHub-pacnpal%2Fvsftpd--conf-181717?logo=github&logoColor=white)](https://github.com/pacnpal/vsftpd-conf) [![Docker Hub](https://img.shields.io/badge/Docker%20Hub-pacnpal%2Fvsftpd--conf-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/r/pacnpal/vsftpd-conf) [![GHCR](https://img.shields.io/badge/GHCR-pacnpal%2Fvsftpd--conf-181717?logo=github&logoColor=white)](https://github.com/pacnpal/vsftpd-conf/pkgs/container/vsftpd-conf) [![GitHub Stars](https://img.shields.io/github/stars/pacnpal/vsftpd-conf?style=social)](https://github.com/pacnpal/vsftpd-conf/stargazers)
[![Build and Push Docker Image](https://github.com/pacnpal/vsftpd-conf/actions/workflows/build.yml/badge.svg)](https://github.com/pacnpal/vsftpd-conf/actions/workflows/build.yml) [![Docker Image Version](https://img.shields.io/docker/v/pacnpal/vsftpd-conf?sort=semver&logo=docker&logoColor=white)](https://hub.docker.com/r/pacnpal/vsftpd-conf/tags) [![GitHub Release](https://img.shields.io/github/v/release/pacnpal/vsftpd-conf?logo=github&logoColor=white)](https://github.com/pacnpal/vsftpd-conf/releases)
[![Docker Pulls](https://img.shields.io/docker/pulls/pacnpal/vsftpd-conf?logo=docker&logoColor=white)](https://hub.docker.com/r/pacnpal/vsftpd-conf) [![Docker Image Size](https://img.shields.io/docker/image-size/pacnpal/vsftpd-conf/latest?logo=docker&logoColor=white)](https://hub.docker.com/r/pacnpal/vsftpd-conf/tags) [![Platforms](https://img.shields.io/badge/platforms-linux%2Famd64%20%7C%20linux%2Farm64-blue?logo=linux&logoColor=white)](https://github.com/pacnpal/vsftpd-conf/pkgs/container/vsftpd-conf) [![License: MIT](https://img.shields.io/github/license/pacnpal/vsftpd-conf?color=blue)](LICENSE)

Minimal Docker image for [vsftpd](https://security.appspot.com/vsftpd.html) that reads its configuration from a bind-mounted file. No entrypoint script, no environment variable handling, no baked-in users. The conf is the source of truth.

## Image

Built for `linux/amd64` and `linux/arm64`. Pull from either registry:

```sh
docker pull ghcr.io/pacnpal/vsftpd-conf:latest
docker pull docker.io/pacnpal/vsftpd-conf:latest
```

Tags: `latest`, `sha-<git-sha>`, and semver tags (`vX.Y.Z`) from git tags.

## Usage

Provide your own `vsftpd.conf` and bind-mount it to `/etc/vsftpd.conf`:

```sh
docker run -d \
  --name vsftpd \
  -v /path/to/vsftpd.conf:/etc/vsftpd.conf:ro \
  -p 21:21 \
  -p 20:20 \
  -p 21100-21110:21100-21110 \
  ghcr.io/pacnpal/vsftpd-conf:latest
```

Publish:

- `21` — control connection
- `20` — active-mode data connection
- A passive port range (e.g. `21100-21110`) — must match `pasv_min_port` / `pasv_max_port` in your conf

If your users need persistent storage, bind-mount their home directories too.

## Required conf settings

Your `vsftpd.conf` **must** include:

```
background=NO
```

Without this, `vsftpd` daemonizes and the container exits immediately.

If you use passive mode (typical for clients behind NAT), set:

```
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110
pasv_address=<your-public-ip-or-host>
```

…and publish the same range with `-p`.

## Logging

The image symlinks `/var/log/vsftpd.log` and `/var/log/xferlog` to `/dev/stdout`, so anything vsftpd logs is visible via `docker logs <container>`. To actually get verbose output, enable it in your conf:

```
syslog_enable=NO
xferlog_enable=YES
xferlog_std_format=NO
log_ftp_protocol=YES
dual_log_enable=YES
vsftpd_log_file=/var/log/vsftpd.log
xferlog_file=/var/log/xferlog
```

- `syslog_enable=NO` — keep file-based logging (the image's symlinks rely on this).
- `xferlog_enable=YES` + `log_ftp_protocol=YES` — log every FTP command and response.
- `dual_log_enable=YES` with `xferlog_std_format=NO` — writes vsftpd's verbose format to `vsftpd_log_file` and xferlog format to `xferlog_file` simultaneously.

If you set `vsftpd_log_file` / `xferlog_file` to non-default paths, the symlinks won't apply — either keep the defaults or symlink your custom paths to `/dev/stdout` yourself (e.g. via a bind-mount).

## License

MIT — see [LICENSE](LICENSE).

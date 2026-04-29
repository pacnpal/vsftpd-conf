# vsftpd-conf

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

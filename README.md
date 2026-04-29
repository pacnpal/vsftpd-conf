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

## License

MIT — see [LICENSE](LICENSE).

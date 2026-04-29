FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends vsftpd \
    && rm -rf /var/lib/apt/lists/* \
    && ln -sf /dev/stdout /var/log/vsftpd.log \
    && ln -sf /dev/stdout /var/log/xferlog

EXPOSE 21

CMD ["vsftpd", "/etc/vsftpd.conf"]

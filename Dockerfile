FROM debian:10
RUN echo 'deb http://deb.debian.org/debian buster-backports main' >> /etc/apt/sources.list.d/buster-backports.list && \
    echo 'deb http://repo.percona.com/percona/apt buster main' >> /etc/apt/sources.list.d/percona-original-release.list && \
    apt update && apt install -y percona-server-client-5.7 s3cmd ca-certificates msmtp && \
    rm -rf /var/lib/apt
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

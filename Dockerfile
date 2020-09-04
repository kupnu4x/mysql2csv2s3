FROM debian:10
RUN echo 'deb http://deb.debian.org/debian buster-backports main' >> /etc/apt/sources.list.d/buster-backports.list && \
    apt update && apt install -y default-mysql-client s3cmd && \
    rm -rf /var/lib/apt
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

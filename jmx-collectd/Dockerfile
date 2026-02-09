FROM debian:trixie

RUN apt update \
 && apt -y upgrade \
 && apt -y --no-install-suggests --no-install-recommends install \
    libcurl3-gnutls \
    libgcrypt20 \
    libriemann-client0 \
    libudev1 \
    default-jre \
    collectd \
    libmicrohttpd12 \
 && apt clean \
 && rm -rf /var/lib/apt/lists/*

COPY ./collectd.conf /etc/collectd/collectd.conf
COPY ./jmx.conf /etc/collectd/collectd.conf.d/jmx.conf

RUN chown -R 10000:10001 /etc/collectd

USER 10000:10001

ENTRYPOINT ["/bin/sh", "-c"]
CMD ["collectd -f"]

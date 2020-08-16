FROM debian:stable-slim as eschalot-builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl build-essential libssl-dev ca-certificates && \
    curl -L https://github.com/ReclaimYourPrivacy/eschalot/archive/master.tar.gz | tar xz && \
    cd eschalot-master && \
    make

FROM debian:stable-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gpg \
    gpg-agent \
    libcap2-bin \
    ca-certificates && \
# See: <https://2019.www.torproject.org/docs/debian.html.en>
    curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import && \
    gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add - && \
    printf "deb https://deb.torproject.org/torproject.org stable main\n" >> /etc/apt/sources.list.d/tor.list \
# Install remaining dependencies.
    apt-get update && apt-get install -y --no-install-recommends \
    tor \
    obfs4proxy && \
# Allow obfs4proxy to bind to ports < 1024.
    setcap cap_net_bind_service=+ep /usr/bin/obfs4proxy && \
# Clean image
    apt-get purge -y curl gpg gpg-agent && \
    apt-get -y autoremove && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/* /root/.gnugp

COPY --from=eschalot-builder /eschalot-master/eschalot /usr/bin/eschalot

COPY torrc /etc/tor/torrc
RUN chown -R debian-tor:debian-tor /etc/tor
RUN chown debian-tor:debian-tor /var/log/tor

COPY docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

USER debian-tor

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["-f", "/etc/tor/torrc"]
FROM debian:stable-slim

ARG VERSION=master
ARG HOST

ENV HOME /safecoin
WORKDIR /safecoin

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      libgomp1 \
      pkg-config \
      m4 \
      autoconf \
      libtool \
      automake \
      curl \
      ca-certificates && \
    curl -L https://github.com/Fair-Exchange/safecoin/archive/$VERSION.tar.gz | tar xz --strip-components=1 && \
    [ "$VERSION" = "master" ] || \
      curl -L https://github.com/Fair-Exchange/safecoin/archive/master.tar.gz | tar xz --strip-components=1 safecoin-master/depends && \
    CXXFLAGS="-Os -ffunction-sections -fdata-sections -Wl,--gc-sections" ./zcutil/build.sh --disable-tests -j$(nproc) && \
    strip -s -R .comment ./src/safecoind && strip -s -R .comment ./src/safecoin-cli && \
    apt-get purge -y \
      build-essential \
      pkg-config \
      m4 \
      autoconf \
      libtool \
      automake && \
    apt-get -y autoremove && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/* && \
    mv ./src/safecoind /usr/bin/safecoind && \
    mv ./src/safecoin-cli /usr/bin/safecoin-cli && \
    mv ./zcutil/fetch-params.sh /usr/bin/fetch-params.sh && \
    rm -rf .[!.]* ..?* *

COPY docker-entrypoint.sh /usr/bin/docker-entrypoint.sh

EXPOSE 8770
EXPOSE 8771

ENTRYPOINT ["docker-entrypoint.sh"]

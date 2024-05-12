################################################################################
# Build a dockerfile for Prosody XMPP server
################################################################################

FROM debian:12

MAINTAINER Prosody Developers <developers@prosody.im>

# Install dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        adduser \
        ca-certificates \
        curl \
        libidn12 \
        libicu72 \
        libicu-dev \
        libssl3 \
        libssl-dev \
        lsb-base \
        lua-bitop \
        lua-dbi-mysql \
        lua-dbi-postgresql \
        lua-dbi-sqlite3 \
        lua-event \
        lua-expat \
        lua-filesystem \
        lua-unbound \
        lua-sec \
        lua-socket \
        lua-zlib \
        lua5.1 \
        lua5.2 \
        lua5.3 \
        lua5.4 \
        make \
        openssl \
        procps \
        ssl-cert \
        sudo \
    && rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80 443 5222 5269 5347 5280 5281
ENV __FLUSH_LOG yes
CMD ["prosody", "-F"]

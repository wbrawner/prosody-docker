################################################################################
# Build a dockerfile for Prosody XMPP server
################################################################################

FROM debian:12

MAINTAINER Prosody Developers <developers@prosody.im>

# Add prosody repository
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
        ca-certificates \
        ssl-cert \
    && curl -Lo /etc/apt/sources.list.d/prosody.sources https://prosody.im/files/prosody.sources

# Install dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        lsb-base \
        procps \
        adduser \
        libidn12 \
        libicu72 \
        libssl3 \
        lua-bitop \
        lua-dbi-mysql \
        lua-dbi-postgresql \
        lua-dbi-sqlite3 \
        lua-event \
        lua-expat \
        lua-filesystem \
        lua-sec \
        lua-socket \
        lua-unbound \
        lua-zlib \
        lua5.1 \
        lua5.2 \
        lua5.3 \
        lua5.4 \
        luarocks \
        openssl \
	prosody \
        sudo \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --set lua-interpreter /usr/bin/lua5.4

# Configure prosody
RUN perl -i -pe 'BEGIN{undef $/;} s/^log = {.*?^}$/log = {\n    {levels = {min = "info"}, to = "console"};\n}/smg' /etc/prosody/prosody.cfg.lua

RUN mkdir -p /var/run/prosody && chown prosody:prosody /var/run/prosody

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80 443 5222 5269 5347 5280 5281
ENV __FLUSH_LOG yes
CMD ["prosody", "-F"]

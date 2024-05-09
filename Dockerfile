################################################################################
# Build a dockerfile for Prosody XMPP server
################################################################################

FROM debian:12

MAINTAINER Prosody Developers <developers@prosody.im>

# Add prosody repository
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && curl -Lo /etc/apt/sources.list.d/prosody.sources https://prosody.im/files/prosody.sources

# Install dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        lsb-base \
        procps \
        adduser \
        libidn11 \
        libicu63 \
        libssl1.1 \
        lua-bitop \
        lua-dbi-mysql \
        lua-dbi-postgresql \
        lua-dbi-sqlite3 \
        lua-event \
        lua-expat \
        lua-filesystem \
        lua-sec \
        lua-socket \
        lua-zlib \
        lua5.1 \
        lua5.2 \
        openssl \
        prosody \
        ca-certificates \
        ssl-cert \
    && rm -rf /var/lib/apt/lists/*

# Install and configure prosody
RUN apt-get install -y --no-recommends prosody \
    && sed -i '1s/^/daemonize = false;\n/' /etc/prosody/prosody.cfg.lua \
    && perl -i -pe 'BEGIN{undef $/;} s/^log = {.*?^}$/log = {\n    {levels = {min = "info"}, to = "console"};\n}/smg' /etc/prosody/prosody.cfg.lua

RUN mkdir -p /var/run/prosody && chown prosody:prosody /var/run/prosody

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80 443 5222 5269 5347 5280 5281
ENV __FLUSH_LOG yes
CMD ["prosody", "-F"]

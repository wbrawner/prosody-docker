#!/bin/bash -e
set -e

ACTUAL_PROSODY_VERSION=${PROSODY_VERSION:-0.12.4}
PROSODY_PATH="/opt/prosody-$ACTUAL_PROSODY_VERSION"

mkdir -p /var/run/prosody && chown prosody:prosody /var/run/prosody

if [ ! -d $PROSODY_PATH ]; then
    curl -Lo- https://prosody.im/downloads/source/prosody-$ACTUAL_PROSODY_VERSION.tar.gz \
        | tar -C /opt -xvf-
    pushd $PROSODY_PATH
    make
    make install
    popd
    cp $PROSODY_PATH/prosody.cfg.lua.dist /etc/prosody/prosody.cfg.lua
    sed -i '1s/^/daemonize = false;\n/' /etc/prosody/prosody.cfg.lua
    perl -i -pe 'BEGIN{undef $/;} s/^log = {.*?^}$/log = {\n    {levels = {min = "info"}, to = "console"};\n}/smg' /etc/prosody/prosody.cfg.lua
fi

data_dir_owner="$(stat -c %u "/var/lib/prosody/")"
if [[ "$(id -u prosody)" != "$data_dir_owner" ]]; then
    usermod -u "$data_dir_owner" prosody
fi
if [[ "$(stat -c %u /var/run/prosody/)" != "$data_dir_owner" ]]; then
    chown "$data_dir_owner" /var/run/prosody/
fi

#if [[ "$1" != "prosody" ]]; then
#    exec prosodyctl "$@"
#    exit 0;
#fi

if [[ "$LOCAL" && "$PASSWORD" && "$DOMAIN" ]]; then
    prosodyctl register "$LOCAL" "$DOMAIN" "$PASSWORD"
fi

PATH=$PROSODY_PATH:$PATH

sudo -Eu prosody -s /usr/bin/bash -- "$@"

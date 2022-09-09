#!/usr/bin/env bash

set -o errexit
set -o pipefail


if [ -z `which packwiz` ]; then
    if [ -z `which go` ]; then
        sudo add-apt-repository -y ppa:longsleep/golang-backports
        sudo apt-get -y update
        sudo apt-get -y install golang-go
    fi
    go install github.com/packwiz/packwiz@latest
    export PATH=~/go/bin:$PATH
fi

echo >&2 "Updating version..."
if [ -z $pack_version ];then
    pack_version="$(rg 'version = "(.*)"' --only-matching --replace '$1' "pack.toml" | cat)"
else
    sed -i "s/^version.*$/version = \"${pack_version}\"/" pack.toml
fi
if [  -f "server-overrides/server.properties" ]; then
    sed -i "s/^motd=.*$/motd=${pack_name} ${pack_version}/" server-overrides/server.properties
fi
if [  -f "client-overrides/config/customwindowtitle-client.toml" ]; then
    sed -i "s/^title = .*$/title = \"${pack_name}-${pack_version}\"/" client-overrides/config/customwindowtitle-client.toml
fi
if [  -f "config/bcc.json" ]; then
    echo "{\"projectID\":0,\"modpackName\":\"${pack_name}\",\"modpackVersion\":\"${pack_version}\",\"useMetadata\":false}" > config/bcc.json
fi

packwiz refresh

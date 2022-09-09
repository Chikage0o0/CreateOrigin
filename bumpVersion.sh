#!/usr/bin/env bash

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


#!/usr/bin/env bash

set -o errexit
set -o pipefail

rm -f ./*.mrpack

if [ -z `which zip` ]; then
    sudo apt-get -y update
    sudo apt-get -y zip
fi

if [ -z `which packwiz` ]; then
    if [ -z `which go` ]; then
        sudo add-apt-repository -y ppa:longsleep/golang-backports
        sudo apt-get -y update
        sudo apt-get -y install golang-go
    fi
    go install github.com/packwiz/packwiz@latest
    export PATH=~/go/bin:$PATH
fi

pack_version="$(grep -oP '(?<=version = \")v[0-9.]+' ./pack.toml)"
pack_name="$(grep -oP '(?<=name = \")[\w\s-_]+' ./pack.toml)"

echo >&2 "Creating mrpack archive for: ${pack_name} ${pack_version}"

# manually downloaded
rm -f ~/.cache/packwiz/cache/import/*
downloadLinks=(
    "https://mediafilez.forgecdn.net/files/3963/321/RoughlyEnoughTrades-1.19-1.0.jar"
)
for downloadLink in ${downloadLinks[@]}
do
    wget -nc -P ~/.cache/packwiz/cache/import/ $downloadLink
done
packwiz modrinth export -o $pack_name-$pack_version.mrpack

echo >&2 "Adding overrides..."
zip --update --recurse-paths \
"$(find -- * -maxdepth 0 -type f -iname '*.mrpack' | head -n1)" \
"client-overrides" "server-overrides"

echo >&2 "done :)"

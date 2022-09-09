#!/usr/bin/env bash

set -o errexit
set -o pipefail

rm -f ./*.mrpack

if [ -z `which rg` ]; then
    sudo apt-get -y update
    sudo apt-get -y install ripgrep
fi

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

pack_version="$(rg 'version = "(.*)"' --only-matching --replace '$1' "pack.toml" | cat)"
pack_name="$(rg 'name = "(.*)"' --only-matching --replace '$1' "pack.toml" | cat)"

echo >&2 "Creating mrpack archive for: ${pack_name} ${pack_version}"

# manually downloaded
rm -f ~/.cache/packwiz/cache/import/*
downloadLinks=(
    "https://drive.939.me/api/raw/?path=/Minecraft/ManuallyDownload/ElytraBombing-Fabric-1.18.X-1.0.0.jar"
    "https://drive.939.me/api/raw/?path=/Minecraft/ManuallyDownload/fabric-experiencebugfix-1.18-18.jar"
    "https://drive.939.me/api/raw/?path=/Minecraft/ManuallyDownload/guard-villagers-fabric-1.18.2-1.0.14.jar"
    "https://drive.939.me/api/raw/?path=/Minecraft/ManuallyDownload/Properly%20Worn%20Backpacks%20(inmis).zip"
    "https://drive.939.me/api/raw/?path=/Minecraft/ManuallyDownload/RoughlyEnoughLootTables-1.18-1.1.jar"
    "https://drive.939.me/api/raw/?path=/Minecraft/ManuallyDownload/RoughlyEnoughTrades-1.1.1.jar"
)
for downloadLink in ${downloadLinks[@]}
do
    wget -nc -q -P ~/.cache/packwiz/cache/import/ $downloadLink
done
packwiz modrinth export

echo >&2 "Adding overrides..."
zip --update --recurse-paths \
"$(find -- * -maxdepth 0 -type f -iname '*.mrpack' | head -n1)" \
"client-overrides" "server-overrides"

echo >&2 "done :)"

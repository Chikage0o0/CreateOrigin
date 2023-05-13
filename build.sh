#!/usr/bin/env bash

set -o errexit
set -o pipefail

rm -f ./*.mrpack
rm -f packwiz-*
rm -rf packwiz

if [ -z `which zip` ]; then
    sudo apt-get -y update
    sudo apt-get -y zip
fi

if [ -z `which go` ]; then
    sudo add-apt-repository -y ppa:longsleep/golang-backports
    sudo apt-get -y update
    sudo apt-get -y install golang-go
fi

git clone https://github.com/packwiz/packwiz && cd packwiz
go build && mv -f packwiz ../packwiz-origin

cat > patch.diff << EOF
diff --git a/modrinth/export.go b/modrinth/export.go
index a471756..e470d50 100644
--- a/modrinth/export.go
+++ b/modrinth/export.go
@@ -272,12 +272,7 @@ var exportCmd = &cobra.Command{
 	},
 }
 
-var whitelistedHosts = []string{
-	"cdn.modrinth.com",
-	"github.com",
-	"raw.githubusercontent.com",
-	"gitlab.com",
-}
+var whitelistedHosts = []string{}
 
 func canBeIncludedDirectly(mod *core.Mod, restrictDomains bool) bool {
 	if mod.Download.Mode == core.ModeURL || mod.Download.Mode == "" {
EOF
git apply patch.diff
go build && mv -f packwiz ../packwiz-mod
cd ..

pack_version="$(grep -oP '(?<=version = \")v[0-9.]+' ./pack.toml)"
pack_name="$(grep -oP '(?<=name = \")[\w\s-_]+' ./pack.toml)"

echo >&2 "Creating mrpack archive for: ${pack_name} ${pack_version}"

# manually downloaded
rm -f ~/.cache/packwiz/cache/import/*
downloadLinks=(
)
for downloadLink in ${downloadLinks[@]}
do
    wget -nc -P ~/.cache/packwiz/cache/import/ $downloadLink
done

./packwiz-origin modrinth export -o "$pack_name-$pack_version.mrpack"
zip --update --recurse-paths "$pack_name-$pack_version.mrpack" "client-overrides" "server-overrides"
./packwiz-mod modrinth export -o "$pack_name-$pack_version-full.mrpack"
zip --update --recurse-paths "$pack_name-$pack_version-full.mrpack" "client-overrides" "server-overrides"

echo >&2 "done :)"

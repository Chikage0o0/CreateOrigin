#!/usr/bin/env bash

JAVA="java"
MINECRAFT="1.19.2"
FABRIC="0.14.17"
INSTALLER="0.11.2"
ARGS="-Xmx4G"
OTHERARGS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1"

if [[ ! -s "eula.txt" ]];then
  echo "Mojang's EULA has not yet been accepted. In order to run a Minecraft server, you must accept Mojang's EULA."
  echo "Mojang's EULA is available to read at https://account.mojang.com/documents/minecraft_eula"
  echo "If you agree to Mojang's EULA then type 'I agree'"
  read ANSWER
  if [[ "$ANSWER" = "I agree" ]]; then
    echo "User agreed to Mojang's EULA."
    echo "#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula)." > eula.txt;
    echo "eula=true" >> eula.txt;
  else
    echo "User did not agree to Mojang's EULA."
  fi
else
  echo "eula.txt present. Moving on...";
fi

echo "Starting server...";
echo "Minecraft version: $MINECRAFT";
echo "Fabric version: $FABRIC";
echo "Java version:"
$JAVA -version
echo "Java args: $ARGS";

$JAVA $OTHERARGS $ARGS -jar fabric-server-mc.${MINECRAFT}-loader.${FABRIC}-launcher.${INSTALLER}.jar nogui

#! /usr/bin/env sh

## EXPERIMENTAL. PROBABLY WON'T SEE THE LIGHT OF DAY BUT MAYBE I GET LUCKY.

# Motivation

git clone https://github.com/eyedeekay/i2p.firefox
cd i2p.firefox || exit 1

. ./config.sh
. ./i2pversion
export machine=unix
echo building launcher
./buildscripts/launcher.sh
cp ../launcher.sh src/I2P/launcher.sh
cp LICENSE.md src
jpackage --name I2P-BUNDLE-APPIMAGE --app-version "$I2P_VERSION" \
    --verbose \
    --java-options "-Xmx512m" \
    --java-options "--add-opens java.base/java.lang=ALL-UNNAMED" \
    --java-options "--add-opens java.base/sun.nio.fs=ALL-UNNAMED" \
    --java-options "--add-opens java.base/java.nio=ALL-UNNAMED" \
    --java-options "--add-opens java.base/java.util.Properties=ALL-UNNAMED" \
    --java-options "--add-opens java.base/java.util.Properties.defaults=ALL-UNNAMED" \
    $JPACKAGE_OPTS \
    --app-content src/I2P/config \
    --app-content src/I2P/launcher.sh \
    --app-content src/icons/windowsUIToopie2.png \
    --app-content src/LICENSE.md \
    --icon src/icons/windowsUIToopie2.png \
    --input build \
    --verbose \
    --type app-image \
    --main-jar launcher.jar \
    --main-class net.i2p.router.WinLauncher

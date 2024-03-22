
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
jpackage --name I2P-BUNDLE --app-version "$I2P_VERSION" \
    --verbose \
    --install-dir /usr/share/ \
    --java-options "-Xmx512m" \
    --java-options "--add-opens java.base/java.lang=ALL-UNNAMED" \
    --java-options "--add-opens java.base/sun.nio.fs=ALL-UNNAMED" \
    --java-options "--add-opens java.base/java.nio=ALL-UNNAMED" \
    --java-options "--add-opens java.base/java.util.Properties=ALL-UNNAMED" \
    --java-options "--add-opens java.base/java.util.Properties.defaults=ALL-UNNAMED" \
    $JPACKAGE_OPTS \
    --app-content src/I2P/config \
    --app-content src/icons/windowsUIToopie2.png \
    --icon src/icons/windowsUIToopie2.png \
    --input build \
    --verbose \
    --type rpm \
    --linux-menu-group "Network;WebBrowser;P2P" \
    --linux-app-category "Network" \
    --linux-shortcut \
    --license-file LICENSE.md \
    --main-jar launcher.jar \
    --main-class net.i2p.router.WinLauncher

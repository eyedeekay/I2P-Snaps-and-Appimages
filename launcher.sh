#! /usr/bin/env sh
if [ ! -d "$SNAP_USER_DATA/config" ]; then
    cp -rv "$SNAP/usr/share/i2p-bundle/lib/config" "$SNAP_USER_DATA/i2p-config"
fi
/usr/share/i2p-bundle/bin/I2P-BUNDLE
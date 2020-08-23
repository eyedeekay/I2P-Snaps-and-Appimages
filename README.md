# I2P-Snaps-and-Appimages

Unofficial I2P Snap and AppImage packages for redistribution.

This repository is primarily for release purposes, but includes
the snapcraft.yaml files required to generate a snap for the
latest release and for the latest development build. When creating
a new release, while logged in to your snapcraft account(i.e.
snapcraft login), increment the I2P version number in **BOTH**
`./i2pi2p/snapcraft.yaml` and in `./Makefile`, and then simply run

        make release

As long as the Docker builds are working, then the snap will build.
We re-use the expect script from the Docker build to automate the
jar install. Just as easy as that :)

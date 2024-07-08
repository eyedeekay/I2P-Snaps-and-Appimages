

USER_GH=eyedeekay
packagename=I2P-Snaps-and-Appimages
VERSION=2.5.7

echo:
	@echo make release to do a release $(VERSION)

version:
	git tag -s -a "i2p-snap-$(VERSION)"

release: version dev stable

stable: release-stable upload-stable pull-stable push-stable

dev: release-dev upload-dev pull-dev push-dev

appimage: pull-stable trick

##export USE_LXD="--use-lxd"

OLD_VERSION=`grep 'version:' i2pi2p/snapcraft.yaml`

update-stable:
	sed -i "s|$(OLD_VERSION)|version: '$(VERSION)'|g" i2pi2p/snapcraft.yaml
	cp -v i2pi2p/snapcraft.yaml i2pi2p-dev/snapcraft.yaml

#release-stable: update-stable (Currently built in CI only, see .github/workflows)
#	cd i2pi2p && \
#		/snap/bin/snapcraft clean $(USE_LXD) && /snap/bin/snapcraft $(USE_LXD)

debug-stable:
	cd i2pi2p && \
		/snap/bin/snapcraft $(USE_LXD) --debug

upload-stable:
		/snap/bin/snapcraft upload --release=stable i2pi2p_$(VERSION)_amd64.snap

#release-dev: (Currently built in CI only, see .github/workflows)
#	cd i2pi2p-dev && \
#		/snap/bin/snapcraft clean $(USE_LXD) && /snap/bin/snapcraft $(USE_LXD)

#upload-dev:
#		/snap/bin/snapcraft upload --release=edge i2pi2p-dev_latest_amd64.snap

pull-stable:
	wget https://github.com/eyedeekay/I2P-Snaps-and-Appimages/releases/download/nightly/i2pi2p_$(VERSION)_amd64.snap

#pull-dev:
#	snap download --edge i2pi2p-dev --basename i2pi2p-dev_latest_amd64

pull: pull-stable pull-dev

test:
	rm -frv *.snap && make pull-stable && sudo snap install --devmode i2pi2p_$(VERSION)_amd64.snap

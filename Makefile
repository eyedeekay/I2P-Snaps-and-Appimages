
VERSION=0.9.46

echo:
	@echo make release to do a release $(VERSION)

release: release-stable upload-stable release-dev upload-dev

release-stable:
	cd i2pi2p && \
		snapcraft

upload-stable:
	cd i2pi2p && \
		snapcraft upload --release=edge i2pi2p_$(VERSION)_amd64.snap

release-dev:
	cd i2pi2p-dev && \
		snapcraft 

upload-dev:
	cd i2pi2p-dev && \
		snapcraft upload --release=edge i2pi2p-dev_latest_amd64.snap

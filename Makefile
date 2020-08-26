

USER_GH=eyedeekay
packagename=I2P-Snaps-and-Appimages
VERSION=0.9.47

echo:
	@echo make release to do a release $(VERSION)

version:
	gothub release -s $(GITHUB_TOKEN) -u $(USER_GH) -r $(packagename) -t v$(VERSION) -d "version $(VERSION)"; true

release: version dev stable

stable: release-stable upload-stable

dev: release-dev upload-dev

release-stable:
	cd i2pi2p && \
		snapcraft clean && snapcraft

upload-stable:
	cd i2pi2p && \
		snapcraft upload --release=edge i2pi2p_$(VERSION)_amd64.snap

release-dev:
	cd i2pi2p-dev && \
		snapcraft clean && snapcraft

upload-dev:
	cd i2pi2p-dev && \
		snapcraft upload --release=edge i2pi2p-dev_latest_amd64.snap

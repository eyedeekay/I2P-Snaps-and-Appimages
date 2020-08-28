

USER_GH=eyedeekay
packagename=I2P-Snaps-and-Appimages
VERSION=0.9.47

echo:
	@echo make release to do a release $(VERSION)

version:
	gothub release -s $(GITHUB_TOKEN) -u $(USER_GH) -r $(packagename) -t v$(VERSION) -d "version $(VERSION)"; true

release: version dev stable

stable: release-stable upload-stable pull-stable push-stable

dev: release-dev upload-dev pull-dev push-dev

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

pull-stable:
	snap download --edge i2pi2p --basename i2pi2p_$(VERSION)_amd64

pull-dev:
	snap download --edge i2pi2p-dev --basename i2pi2p-dev_latest_amd64

pull: pull-stable pull-dev

sumlinux=`sha256sum i2pi2p_$(VERSION)_amd64.snap`
sumlinuxassert=`sha256sum i2pi2p_$(VERSION)_amd64.assert`

push-stable:
	gothub upload -R -u eyedeekay -r "v$(VERSION)" -t $(packagename) -l "$(sumlinux)" -n "i2pi2p_$(VERSION)_amd64.snap" -f "i2pi2p_$(VERSION)_amd64.snap"
	gothub upload -R -u eyedeekay -r "v$(VERSION)" -t $(packagename) -l "$(sumlinuxassert)" -n "i2pi2p_$(VERSION)_amd64.assert" -f "i2pi2p_$(VERSION)_amd64.assert"

sumlinux=`sha256sum i2pi2p-dev_latest_amd64.snap`
sumlinuxassert=`sha256sum i2pi2p-dev_latest_amd64.assert`

push-dev:
	gothub upload -R -u eyedeekay -r "v$(VERSION)" -t $(packagename) -l "$(sumlinux)" -n "i2pi2p-dev_latest_amd64.snap" -f "i2pi2p-dev_latest_amd64.snap"
	gothub upload -R -u eyedeekay -r "v$(VERSION)" -t $(packagename) -l "$(sumlinux)" -n "i2pi2p-dev_latest_amd64.asset" -f "i2pi2p-dev_latest_amd64.assert"

push: push-stable push-dev

mirror: pull-stable push-stable pull-dev push-dev




USER_GH=eyedeekay
packagename=I2P-Snaps-and-Appimages
VERSION=2.2.0

echo:
	@echo make release to do a release $(VERSION)

version:
	gothub release -s $(GITHUB_TOKEN) -u $(USER_GH) -r $(packagename) -t v$(VERSION) -d "version $(VERSION)"; true

release: version dev stable

stable: release-stable upload-stable pull-stable push-stable

dev: release-dev upload-dev pull-dev push-dev

appimage: pull-stable trick

##export USE_LXD="--use-lxd"

OLD_VERSION=`grep 'version:' i2pi2p/snapcraft.yaml`

update-stable:
	sed -i "s|$(OLD_VERSION)|version: '$(VERSION)'|g" i2pi2p/snapcraft.yaml

release-stable: update-stable
	cd i2pi2p && \
		/snap/bin/snapcraft clean $(USE_LXD) && /snap/bin/snapcraft $(USE_LXD)

debug-stable:
	cd i2pi2p && \
		/snap/bin/snapcraft $(USE_LXD) --debug

upload-stable:
	cd i2pi2p && \
		/snap/bin/snapcraft upload --release=stable i2pi2p_$(VERSION)_amd64.snap

release-dev:
	cd i2pi2p-dev && \
		/snap/bin/snapcraft clean $(USE_LXD) && /snap/bin/snapcraft $(USE_LXD)

upload-dev:
	cd i2pi2p-dev && \
		/snap/bin/snapcraft upload --release=edge i2pi2p-dev_latest_amd64.snap

pull-stable:
	snap download --edge i2pi2p --basename i2pi2p_$(VERSION)_amd64

pull-dev:
	snap download --edge i2pi2p-dev --basename i2pi2p-dev_latest_amd64

pull: pull-stable pull-dev

sumlinux=`sha256sum i2pi2p_$(VERSION)_amd64.snap`
sumlinuxassert=`sha256sum i2pi2p_$(VERSION)_amd64.assert`

push-stable:
	gothub upload -R -u eyedeekay -t "v$(VERSION)" -r $(packagename) -l "$(sumlinux)" -n "i2pi2p_$(VERSION)_amd64.snap" -f "i2pi2p_$(VERSION)_amd64.snap"
	gothub upload -R -u eyedeekay -t "v$(VERSION)" -r $(packagename) -l "$(sumlinuxassert)" -n "i2pi2p_$(VERSION)_amd64.assert" -f "i2pi2p_$(VERSION)_amd64.assert"

sumlinuxdev=`sha256sum i2pi2p-dev_latest_amd64.snap`
sumlinuxdevassert=`sha256sum i2pi2p-dev_latest_amd64.assert`

push-dev:
	gothub upload -R -u eyedeekay -t "v$(VERSION)" -r $(packagename) -l "$(sumlinuxdev)" -n "i2pi2p-dev_latest_amd64.snap" -f "i2pi2p-dev_latest_amd64.snap"
	gothub upload -R -u eyedeekay -t "v$(VERSION)" -r $(packagename) -l "$(sumlinuxdevassert)" -n "i2pi2p-dev_latest_amd64.assert" -f "i2pi2p-dev_latest_amd64.assert"

appimagesum=`sha256sum Invisible_Internet_Project-x86_64.AppImage`

push-appimage: appimage
	gothub upload -R -u eyedeekay -t "v$(VERSION)" -r $(packagename) -l "$(appimagesum)" -n "Invisible_Internet_Project-x86_64.AppImage" -f "Invisible_Internet_Project-x86_64.AppImage"

push: push-stable push-dev

mirror: pull-stable push-stable pull-dev push-dev

AppRun:
	@echo "#!/bin/sh"  | tee AppRun
	@echo export SNAP="$$APPDIR" | tee -a AppRun
	@echo export SNAP_ARCH="amd64" | tee -a AppRun
	@echo export SNAP_VERSION="3"  | tee -a AppRun # for example (get the version from the original snap) tee -a AppRun
	@echo export SNAP_USER_DATA="$$HOME/snap" | tee -a AppRun
	@echo export JAVA_HOME=$SNAP/usr/lib/jvm/java-11-openjdk-amd64 | tee -a AppRun
	@echo export PATH=$$JAVA_HOME/jre/bin:/usr/local/bin:/usr/bin:/bin:/snap/bin | tee -a AppRun
	@echo "\$$APPDIR/runplain.sh" | tee -a AppRun

i2p.desktop:
	@echo "[Desktop Entry]" | tee i2p.desktop
	@echo "Name=Invisible Internet Project" | tee -a i2p.desktop
	@echo "Exec=profile/i2pbrowser.sh" | tee -a i2p.desktop
	@echo "Type=Application" | tee -a i2p.desktop
	@echo "Icon=i2plogo" | tee -a i2p.desktop
	@echo "Categories=X-net;" | tee -a i2p.desktop
	@echo "" | tee -a i2p.desktop

trick: umnt AppRun i2p.desktop mnt
	sudo cp -a ./i2pi2p-snap ./"Invisible Internet Project_x86-64"
	@echo 0
	sudo cp AppRun "Invisible Internet Project_x86-64"/AppRun
	@echo 1
	sudo chmod +x AppRun "Invisible Internet Project_x86-64"/AppRun
	@echo 2
	sudo cp i2p.desktop "Invisible Internet Project_x86-64"/i2p.desktop
	@echo 3
	sudo cp "Invisible Internet Project_x86-64"/docs/themes/console/images/i2plogo.png "Invisible Internet Project_x86-64"/i2plogo.png
	@echo 4
	sudo ./appimagetool-x86_64.AppImage "Invisible Internet Project_x86-64"
	@echo 5
	make umnt

mnt:
	sudo rm -rf "Invisible Internet Project_x86-64" "Invisible Internet Project"
	mkdir -p i2pi2p-snap
	sudo mount -t squashfs -o ro i2pi2p/i2pi2p_"$(VERSION)"_amd64.snap i2pi2p-snap

umnt:
	sudo umount i2pi2p-snap; true

artifacts:
	git clone https://i2pgit.org/i2p-hackers/i2p.firefox -b EXPERIMENTAL-jpackage; true
	git clone https://i2pgit.org/i2p-hackers/i2p.i2p; true
	cd i2p.firefox && \
		./build.sh && \
		make profile.tgz app-profile.tgz

upload-snap-artifacts:
	github-release delete -u eyedeekay -r I2P-Snaps-and-Appimages -t pre-$(VERSION); true
	github-release release -p -u eyedeekay -r I2P-Snaps-and-Appimages -t pre-$(VERSION) -n $(VERSION) -d "Artifacts for putting to Snap packages."; true
	sleep 1s;
	github-release upload -R -u eyedeekay -r I2P-Snaps-and-Appimages -t pre-$(VERSION) -n "UNOFFICIAL FOR SNAP USE ONLY i2p-bundle_$(VERSION).deb" -f i2p.firefox/i2p-bundle_$(VERSION)_amd64.deb


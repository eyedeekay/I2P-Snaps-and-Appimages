#!/bin/bash
set -e 

if [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
	JAVA=$(java --version | tr -d 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\n' | cut -d ' ' -f 2 | cut -d '.' -f 1 | tr -d '\n\t ')

	if [ "$JAVA" -lt "14" ]; then
		echo "Java 14+ must be used to compile with jpackage, java is $JAVA"
		exit 1
	fi


	if [ -z "${JAVA_HOME}" ]; then
		JAVA_HOME=`type -p java|xargs readlink -f|xargs dirname|xargs dirname`
		echo "Building with: $JAVA, $JAVA_HOME"
	fi

	if [ ! -d ../i2p.i2p ]; then
		git clone https://github.com/i2p/i2p.i2p ../i2p.i2p $@
	fi
	if [ ! -d ../i2p.firefox ]; then
		git clone https://github.com/i2p/i2p.firefox ../i2p.firefox -b EXPERIMENTAL-jpackage
	fi

	echo "cleaning"
	./clean.sh

	HERE="$PWD"
	cd ../i2p.i2p
	ant updater
	cd $HERE
	cd ../i2p.firefox
	make prep && make checkinstall
	cp -v *.deb "$HERE"
	cd $HERE
	RES_DIR="$HERE/../i2p.i2p/installer/resources"
	I2P_JARS="$HERE/../i2p.i2p/pkg-temp/lib"
	I2P_PKG="$HERE/../i2p.i2p/pkg-temp"


	echo "preparing resources.csv"
	mkdir -p build
	cd "$RES_DIR"
	find certificates -name *.crt -exec echo '{},{},true' >> "$HERE"/build/resources.csv \;
	echo "config/hosts.txt,hosts.txt,false" >> "$HERE"/build/resources.csv
	echo "preparing webapps"
	cd "$I2P_PKG"
	find webapps -name '*.war' -exec echo '{},{},true' >> "$HERE"/build/resources.csv \;
	# TODO add others
	cd "$HERE"
	echo "geoip/GeoLite2-Country.mmdb,geoip/GeoLite2-Country.mmdb,true" >> build/resources.csv
	# TODO: decide on blocklist.txt

	sed -i.bak 's|\./||g' build/resources.csv

	echo "copying certificates"
	cp -R "$RES_DIR"/certificates build/
	echo "copying config"
	mkdir -p build/config
	cp -R "$RES_DIR"/i2ptunnel.config build/config
	cp -R "$RES_DIR"/clients.config build/config
	cp -R "$RES_DIR"/wrapper.config build/config
	cp ../i2p.firefox/LICENSE LICENSE
	echo "routerconsole.browser=/usr/local/bin/i2pconfig" | tee build/config/router.config

	cd build/config
	find . -name '*.config' -exec echo 'config/{},{},false' >> "$HERE"/build/resources.csv \;
	cd "$HERE"

	cp -R "$RES_DIR"/hosts.txt build/config/hosts.txt
	cp -R "$I2P_PKG"/webapps build/

	echo "copying GeoIP"
	mkdir -p build/geoip
	cp "$RES_DIR"/GeoLite2-Country.mmdb.gz build/geoip
	gunzip build/geoip/GeoLite2-Country.mmdb.gz

	echo "compiling custom launcher"
	cp "$I2P_JARS"/*.jar build
	cd java
	"$JAVA_HOME"/bin/javac -d ../build -classpath ../build/i2p.jar:../build/router.jar net/i2p/router/PackageLauncher.java
	cd ..

	echo "building launcher.jar"
	cd build
	"$JAVA_HOME"/bin/jar -cf launcher.jar net certificates geoip config webapps resources.csv
	cd ..

	if [ -z $I2P_VERSION ]; then 
	    I2P_VERSION=$("$JAVA_HOME"/bin/java -cp build/router.jar net.i2p.router.RouterVersion | sed "s/.*: //" | head -n 1)
	fi
	echo "preparing to invoke jpackage for I2P version $I2P_VERSION"

	"$JAVA_HOME"/bin/jpackage --name I2P --app-version "$I2P_VERSION" \
		--verbose \
		$JPACKAGE_OPTS \
		--resource-dir build \
		--license LICENSE
		--input build --main-jar launcher.jar --main-class net.i2p.router.PackageLauncher
fi

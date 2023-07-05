#!/bin/sh

# not enabling `errtrace` and `pipefail` since those are bash specific
set -o errexit # failing commands causes script to fail
set -o nounset # undefined variables causes script to fail

echo "src/gz packages_ci file:///ci" >> /etc/opkg/distfeeds.conf

FINGERPRINT="$(usign -F -p /ci/packages_ci.pub)"
cp /ci/packages_ci.pub "/etc/opkg/keys/$FINGERPRINT"

mkdir -p /var/lock/

opkg update

[ -n "${CI_HELPER:=''}" ] || CI_HELPER="/ci/.github/workflows/ci_helpers.sh"

for PKG in /ci/*.ipk; do
	tar -xzOf "$PKG" ./control.tar.gz | tar xzf - ./control
	# package name including variant
	PKG_NAME=$(sed -ne 's#^Package: \(.*\)$#\1#p' ./control)
	# package version without release
	PKG_VERSION=$(sed -ne 's#^Version: \(.*\)-[0-9]*$#\1#p' ./control)
	# package source contianing test.sh script
	PKG_SOURCE=$(sed -ne 's#^Source: .*/\(.*\)$#\1#p' ./control)

	echo "Testing package $PKG_NAME in version $PKG_VERSION from $PKG_SOURCE"

	export PKG_NAME PKG_VERSION CI_HELPER

	PRE_TEST_SCRIPT=$(find /ci/ -name "$PKG_SOURCE" -type d)/pre-test.sh

	if [ -f "$PRE_TEST_SCRIPT" ]; then
		echo "Use package specific pre-test.sh"
		if sh "$PRE_TEST_SCRIPT" "$PKG_NAME" "$PKG_VERSION"; then
			echo "Pre-test successful"
		else
			echo "Pre-test failed"
			exit 1
		fi
	else
		echo "No pre-test.sh script available"
	fi

	opkg install "$PKG"

	TEST_SCRIPT=$(find /ci/ -name "$PKG_SOURCE" -type d)/test.sh

	if [ -f "$TEST_SCRIPT" ]; then
		echo "Use package specific test.sh"
		if sh "$TEST_SCRIPT" "$PKG_NAME" "$PKG_VERSION"; then
			echo "Test successful"
		else
			echo "Test failed"
			exit 1
		fi
	else
		echo "Use generic test"
	        PKG_FILES=$(opkg files "$PKG_NAME" | grep -E "/bin|/sbin|/usr/bin|/usr/sbin")
		SUCCESS=0
		FOUND_EXE=0
		for FILE in $PKG_FILES; do
			if [ -x "$FILE" ] && [ -f "$FILE" ]; then
				FOUND_EXE=1
				echo "Test executable $FILE"
				for V in --version -version version -v -V; do
					echo "Trying $FILE $V"
					if "$FILE" "$V" 2>&1 | grep "$PKG_VERSION"; then
						SUCCESS=1
						break
					fi
				done

			fi
		done
		if [ "$FOUND_EXE" -eq 1 ]; then
			if [ "$SUCCESS" -eq 0 ]; then
				echo "Generic test failed"
				exit 1
			else
				echo "Test succesful or"
			fi
		else
			echo "No executeable found in package $PKG_NAME"
		fi
	fi

	opkg remove "$PKG_NAME" --force-removal-of-dependent-packages --force-remove --autoremove || true
done

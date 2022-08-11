#!/bin/sh
set -e

UBUNTU_SERIES=$1

if [ "x$1" = "x" ]; then
	UBUNTU_SERIES="16"
	echo "  [!!!] Ubuntu series not defined, defaulting to 16."
	echo "  [!!!] To get this value, please run 'snap version' on a similar operating system"
fi

echo "  => Installing snapcraft"

# install dependencies
echo "  => Installing dependencies"
apt-get install -y curl jq squashfs-tools

# grab_snap(name)
grab_snap() {
	echo "  => Grabbing snap $1..."
	curl -L $(curl -H "X-Ubuntu-Series: $UBUNTU_SERIES" "https://api.snapcraft.io/api/v1/snaps/details/$1?channel=stable" | jq ".download_url" -r) --output ${1}.snap
	mkdir -p /snap/$1
	unsquashfs -d /snap/$1/current ${1}.snap
	rm ${1}.snap
	echo "  => Grabbed snap $1"
}

# Get required snaps
grab_snap core
grab_snap core18
grab_snap core20
grab_snap snapcraft

echo "  => Fixing Python3 installation"
unlink /snap/snapcraft/current/usr/bin/python3
ln -s /snap/snapcraft/current/usr/bin/python3.* /snap/snapcraft/current/usr/bin/python3
echo /snap/snapcraft/current/lib/python3.*/site-packages >> /snap/snapcraft/current/usr/lib/python3/dist-packages/site-packages.pth

echo "  => Creating snapcraft runner"
mkdir -p /snap/bin
echo "#!/bin/sh" > /snap/bin/snapcraft
SNAP_VERSION="$(awk '/^version:/{print $2}' /snap/snapcraft/current/meta/snap.yaml)"
echo "export SNAP_VERSION=\"$SNAP_VERSION\"" >> /snap/bin/snapcraft
echo 'exec $SNAP/usr/bin/python3 $SNAP/bin/snapcraft "$@"' >> /snap/bin/snapcraft
chmod +x /snap/bin/snapcraft

echo "  => Installing snapd"
apt-get install -y snapd sudo locales
locale-gen en_US.UTF-8

echo "  [N] Please don't forget to add these to your dockerfile:"
echo "-----------------------------------------"
echo 'ENV LANG="en_US.UTF-8"'
echo 'ENV LANGUAGE="en_US:en"'
echo 'ENV LC_ALL="en_US.UTF-8"'
echo 'ENV PATH="/snap/bin:/snap/snapcraft/current/usr/bin:$PATH"'
echo 'ENV SNAP="/snap/snapcraft/current"'
echo 'ENV SNAP_NAME="snapcraft"'
echo 'ENV SNAP_ARCH="amd64"'
echo "-----------------------------------------"

echo "  => DONE"

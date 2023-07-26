#!/bin/bash

ARCHS="amd64 i386"
DEBIAN_DISTRO="buster bullseye bookworm unstable"
UBUNTU_DISTRO="bionic focal jammy kinetic lunar"
EXPORT_PATH="/home/jenkins/"
GIT_BASE_URL=https://github.com/llvm/llvm-project
GIT_TOOLCHAIN_CHECK=https://github.com/opencollab/llvm-toolchain-integration-test-suite.git

if test -d $EXPORT_PATH/llvm-project; then
    echo "Updating repo in $EXPORT_PATH/llvm-project"
    # Update it
    git pull
else
    # Download it
    echo "Cloning the repo in $EXPORT_PATH/llvm-project"
    git clone $GIT_BASE_URL $EXPORT_PATH/llvm-project
fi

if test -d $EXPORT_PATH/llvm-toolchain-integration-test-suite; then
    echo "Updating repo in $EXPORT_PATH/llvm-toolchain-integration-test-suite"
    # Update it
    git pull
else
    echo "Clone llvm-toolchain-integration-test-suite into $EXPORT_PATH/llvm-toolchain-integration-test-suite"
    git clone $GIT_TOOLCHAIN_CHECK $EXPORT_PATH/llvm-toolchain-integration-test-suite
fi


cat > /tmp/configfile  <<EOF
COMPONENTS="main universe"
EOF

for d in $DEBIAN_DISTRO; do
    if test "$d" == "bookworm"; then
    # The cloudfront mirror is failing on:
    # E: The repository 'http://cloudfront.debian.net//debian bookworm Release' no longer has a Release file.
        DEBIAN_MIRROR=http://deb.debian.org/debian/
    else
        DEBIAN_MIRROR=http://cloudfront.debian.net/debian/
    fi
    for a in $ARCHS; do
        echo $a
        echo $d
        if test -d /var/cache/pbuilder/base-$d-$a.cow; then
            sudo DIST=$d ARCH=$a cowbuilder --update --basepath /var/cache/pbuilder/base-$d-$a.cow
        else
            sudo DIST=$d ARCH=$a cowbuilder --create --basepath /var/cache/pbuilder/base-$d-$a.cow --distribution $d --debootstrap debootstrap --mirror $DEBIAN_MIRROR --architecture $a --debootstrapopts --arch --debootstrapopts $a --debootstrapopts --variant=buildd --hookdir /usr/share/jenkins-debian-glue/pbuilder-hookdir/
        fi
    done
done

for d in $UBUNTU_DISTRO; do
    echo $d
    a=amd64
    if test -d /var/cache/pbuilder/base-$d-$a.cow; then
        sudo DIST=$d ARCH=$a cowbuilder --update --basepath /var/cache/pbuilder/base-$d-$a.cow
    else
        sudo DIST=$d ARCH=$a cowbuilder --create --basepath /var/cache/pbuilder/base-$d-$a.cow --distribution $d --debootstrap debootstrap --architecture $a --debootstrapopts --arch --debootstrapopts $a --debootstrapopts --variant=buildd --configfile=/tmp/configfile --hookdir /usr/share/jenkins-debian-glue/pbuilder-hookdir/
    fi
done
rm -f /tmp/configfile

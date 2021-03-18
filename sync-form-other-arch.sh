#!/bin/bash
set -e

if test $# -ne 3; then
    echo "error"
    echo "syntax $0 DISTRO HOST ARCH"
    exit 1
fi

DISTRO=$1
HOST=$2
ARCH=$3
rsync -avzh --delete jenkins@$HOST:/srv/repository/$DISTRO/ /tmp/tmp-$DISTRO/
if ! test -d /tmp/tmp-$DISTRO/pool/main/; then
        echo "Distro $DISTRO not existing yet"
        exit 0
fi

for f in /tmp/tmp-$DISTRO/dists/llvm-*/main/binary-$ARCH/; do
	echo $f
        VERSION=$(echo $f|sed -e "s|/tmp/tmp-$DISTRO/dists/llvm-toolchain-$DISTRO-\([[:digit:]]\+\)/.*|\1|g")
	echo "VERSION $VERSION"
	re='^[0-9]+$'
	if ! [[ $VERSION =~ $re ]] ; then
            # maybe debian unstable
            VERSION=$(echo $f|sed -e "s|/tmp/tmp-$DISTRO/dists/llvm-toolchain-\([[:digit:]]\+\)/.*|\1|g")
            if ! [[ $VERSION =~ $re ]] ; then
                echo "VERSION not found"
                exit 0
            fi
	fi
	if test $DISTRO == "unstable"; then
	    reprepro -Vb /srv/repository/$DISTRO/ includedeb llvm-toolchain-$VERSION /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain-$VERSION/*deb
	else
            reprepro -Vb /srv/repository/$DISTRO/ includedeb llvm-toolchain-$DISTRO-$VERSION /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain-$VERSION/*deb
	fi
done

if test -d /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain/; then
    if test $DISTRO == "unstable"; then
	reprepro -Vb /srv/repository/$DISTRO/ includedeb llvm-toolchain /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain/*deb
    else
        reprepro -Vb /srv/repository/$DISTRO/ includedeb llvm-toolchain-$DISTRO /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain/*deb
    fi

fi

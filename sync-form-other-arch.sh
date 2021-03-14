#!/bin/bash
set -e

if test $# -ne 2; then
    echo "error"
    echo "syntax $0 DISTRO HOST"
    exit 1
fi

DISTRO=$1
HOST=$2
#rsync -avzh jenkins@$HOST:/srv/repository/$DISTRO/ /tmp/tmp-$DISTRO/
if ! test -d /tmp/tmp-$DISTRO/pool/main/; then
        echo "Distro $DISTRO not existing yet"
        exit 0
fi

for f in /tmp/tmp-$DISTRO/dists/llvm-*; do
	echo $f
	VERSION=$(echo $f|sed -e "s|/tmp/tmp-$DISTRO/dists/llvm-toolchain-$DISTRO-\(.*\)|\1|g")
	echo "VERSION $VERSION"
        if test -z $VERSION; then
                echo "VERSION not found"
                exit 0
        fi
	reprepro -Vb /srv/repository/$DISTRO/ includedeb llvm-toolchain-$DISTRO-$VERSION /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain-$VERSION/*deb
done

if test -d /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain/; then
	reprepro -Vb /srv/repository/$DISTRO/ includedeb llvm-toolchain-$DISTRO /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain/*deb
fi

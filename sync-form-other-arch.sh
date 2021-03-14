#!/bin/bash
set -e

if test $# -ne 2; then
    echo "error"
    echo "syntax $0 DISTRO HOST"
    exit 1
fi

DISTRO=$1
HOST=$2
rsync -avzh jenkins@$HOST:/srv/repository/$DISTRO/ /tmp/tmp-$DISTRO/
if ! test -d /tmp/tmp-$DISTRO/srv/repository/$DISTRO/dists/; then
	echo "Distro $DISTRO not existing yet"
	exit 0
fi
for f in  /tmp/tmp-$DISTRO/srv/repository/$DISTRO/dists/llvm-*; do
	VERSION=$(echo $f|sed -e "s|/srv/repository/.*/dists/llvm-toolchain-$DISTRO-\(.*\)|\1|g")
	if test -z $VERSION; then
		echo "VERSION not found"
		exit 0
	fi
	reprepro -Vb /srv/repository/$DISTRO/ includedeb llvm-toolchain-$DISTRO-$VERSION /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain-$VERSION/*deb
done
if test -d /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain/; then
	reprepro -Vb /srv/repository/$DISTRO/ includedeb llvm-toolchain-$DISTRO /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain/*deb
fi
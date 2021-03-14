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
for f in /srv/repository/$DISTRO/dists/llvm-*; do
	VERSION=$(echo $f|sed -e "s|/srv/repository/.*/dists/llvm-toolchain-$DISTRO-\(.*\)|\1|g")
	reprepro -Vb /srv/repository/$DISTRO/ includedeb llvm-toolchain-$DISTRO-$VERSION /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain-$VERSION/*deb
done
if test -d /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain/; then
	reprepro -Vb /srv/repository/$DISTRO/ includedeb llvm-toolchain-$DISTRO /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain/*deb
fi

#!/bin/bash
set -e
WHOAMI=$(whoami)

if test $WHOAMI != "jenkins"; then
	echo "should be run under jenkins"
fi

if test $# -ne 1 -a $# -ne 2; then
	echo "Wrong number of args."
	echo "Syntax: $0 <repository> <skip sync>"
	exit 1
fi

if ! grep -q XXX= ~/.ssh/known_hosts; then
	echo "Key unknown. added"
	echo "XXX" >> ~/.ssh/known_hosts
fi


REPOSITORY=$1
SKIP_SYNC=$2
TARGET=XXXX@XXX.llvm.org
BASE_TARGETDIR=/data/apt/www
BASE_LOCALDIR=/srv/repository
if test ! -d $BASE_LOCALDIR/$REPOSITORY; then
	echo "Cannot find directory $REPOSITORY"
	exit 1
fi

LLVM_DEFAULT_DIR=$BASE_LOCALDIR/$REPOSITORY/pool/main/l/llvm-defaults/
if test ! -d $LLVM_DEFAULT_DIR/; then
        echo "Cannot find directory $LLVM_DEFAULT_DIR"
        exit 1
fi

if test -z "$SKIP_SYNC"; then
find $BASE_LOCALDIR -type d | xargs chmod 755 || true
find $BASE_LOCALDIR -type f ! -name sync-to-llvm.sh | xargs -I {}  -d '\n' chmod 644 "{}" || true
ssh $TARGET mkdir -p $BASE_TARGETDIR/$REPOSITORY
echo "Delete potential old directory"
time ssh $TARGET rm -rf $BASE_TARGETDIR/$REPOSITORY.back
echo "Copy the current repo to a new directory to be updated"
time ssh $TARGET cp -Rp $BASE_TARGETDIR/$REPOSITORY $BASE_TARGETDIR/$REPOSITORY.back
echo "Sync the data"
time /usr/bin/rsync -a --info=progress2 --times --delete -v --stats -r $BASE_LOCALDIR/$REPOSITORY/* $TARGET:$BASE_TARGETDIR/$REPOSITORY.back/
echo "Kill the current repo (by renaming it)"
time ssh $TARGET mv $BASE_TARGETDIR/$REPOSITORY $BASE_TARGETDIR/$REPOSITORY.1
echo "Move the new repo to the actual dir"
time ssh $TARGET mv $BASE_TARGETDIR/$REPOSITORY.back $BASE_TARGETDIR/$REPOSITORY
echo "Delete the old repo"
time ssh $TARGET rm -rf $BASE_TARGETDIR/$REPOSITORY.1
fi

key="xxxx"
if test "$REPOSITORY" == "unstable"; then
    REPOSITORY_CODE=""
else
    REPOSITORY_CODE="-$REPOSITORY"
fi
archs="i386 amd64 s390x"
for f in $arch; do
    url="binary-$arch/Packages.gz binary-$arch/Packages binary-$arch/Release binary-$arch/Release"
    for f in $url; do
        curl -XPOST -H "Fastly-Key:$key" https://api.fastly.com/purge/apt.llvm.org/$REPOSITORY/dists/llvm-toolchain$REPOSITORY_CODE/main/$f
    done
done
url="InRelease Release Release.gpg"
for f in $url; do
    curl -XPOST -H "Fastly-Key:$key" https://api.fastly.com/purge/apt.llvm.org/$REPOSITORY/dists/llvm-toolchain$REPOSITORY_CODE/$f
done

curl -XPOST -H "Fastly-Key:$key" https://api.fastly.com/purge/apt.llvm.org/$REPOSITORY/


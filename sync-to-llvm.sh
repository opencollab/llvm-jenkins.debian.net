#!/bin/bash
set -e
WHOAMI=$(whoami)

if test $WHOAMI != "jenkins"; then
	echo "should be run under jenkins"
fi

if test $# -ne 1; then
	echo "Wrong number of args."
	echo "Syntax: $0 <repository>"
	exit 1
fi

REPOSITORY=$1
TARGET=apt@apt-origin.llvm.org
BASE_TARGETDIR=/data/apt/www
BASE_LOCALDIR=/srv/repository
if test ! -d $BASE_LOCALDIR/$REPOSITORY; then
	echo "Cannot find directory $REPOSITORY"
	exit 1
fi
find $BASE_LOCALDIR -type d | xargs chmod 755
find $BASE_LOCALDIR -type f ! -name sync-to-llvm.sh | xargs -I {}  -d '\n' chmod 644 "{}" || true
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

key="TO UDPATE"
if test "$REPOSITORY" == "unstable"; then
    REPOSITORY_CODE=""
else
    REPOSITORY_CODE="-$REPOSITORY"
fi
url="binary-i386/Packages.gz binary-amd64/Packages.gz binary-i386/Packages binary-amd64/Packages binary-i386/Release binary-amd64/Release"
for f in $url; do
curl -XPOST -H "Fastly-Key:$key" https://api.fastly.com/purge/apt.llvm.org/$REPOSITORY/dists/llvm-toolchain$REPOSITORY_CODE/main/$f
done
url="InRelease Release Release.gpg"
for f in $url; do
curl -XPOST -H "Fastly-Key:$key" https://api.fastly.com/purge/apt.llvm.org/$REPOSITORY/dists/llvm-toolchain$REPOSITORY_CODE/$f
done

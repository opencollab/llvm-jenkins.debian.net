#!/bin/bash -v

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
find $BASE_LOCALDIR -type f ! -name sync-to-llvm.sh | xargs chmod 644
time ssh $TARGET cp -R $BASE_TARGETDIR/$REPOSITORY $BASE_TARGETDIR/$REPOSITORY.back
time /usr/bin/rsync --delay-updates --info=progress2 --block-size=131072 --protocol=29 --times --delete -v --stats -r $BASE_LOCALDIR/$REPOSITORY/* $TARGET:$BASE_TARGETDIR/$REPOSITORY.back/
time ssh $TARGET mv $BASE_TARGETDIR/$REPOSITORY $BASE_TARGETDIR/$REPOSITORY.1
time ssh $TARGET mv $BASE_TARGETDIR/$REPOSITORY.back $BASE_TARGETDIR/$REPOSITORY
time ssh $TARGET rm -rf $BASE_TARGETDIR/$REPOSITORY.1

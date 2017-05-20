#!/bin/bash

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
time /usr/bin/rsync --delay-updates --times -v --stats --delete -r $BASE_LOCALDIR/$REPOSITORY $TARGET:$BASE_TARGETDIR/
#ssh $TARGET mv $BASE_TARGETDIR/www/$REPOSITORY $BASE_TARGETDIR/www/$REPOSITORY.back
#ssh $TARGET mv $BASE_TARGETDIR/tmp-repo/$REPOSITORY $BASE_TARGETDIR/www/$REPOSITORY
#ssh $TARGET rm -rf $BASE_TARGETDIR/www/$REPOSITORY.back

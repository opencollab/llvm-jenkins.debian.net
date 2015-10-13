#!/bin/bash

if test $# -ne 1; then
	echo "Wrong number of args."
	echo "Syntax: $0 <repository>"
	exit 1
fi

REPOSITORY=$1
TARGET=apt@llvm.org
BASE_TARGETDIR=/home/apt
BASE_LOCALDIR=/srv/repository
if test ! -d $BASE_LOCALDIR/$REPOSITORY; then
	echo "Cannot find directory $REPOSITORY"
	exit 1
fi

time /usr/bin/rsync -v --stats --delete -r $BASE_LOCALDIR/$REPOSITORY $TARGET:$BASE_TARGETDIR/www/
#ssh $TARGET mv $BASE_TARGETDIR/www/$REPOSITORY $BASE_TARGETDIR/www/$REPOSITORY.back
#ssh $TARGET mv $BASE_TARGETDIR/tmp-repo/$REPOSITORY $BASE_TARGETDIR/www/$REPOSITORY
#ssh $TARGET rm -rf $BASE_TARGETDIR/www/$REPOSITORY.back

#!/bin/bash
# sh create-new-job.sh precise 3.5 release_35 3.5
# sh create-new-job.sh unstable 3.5 release_35 3.5

if test $# -ne 4; then
    echo "Syntax:"
    echo "$0 distribution name SVNbranch_upstream SVNbranch_debian"
    exit 1
fi

DISTRIBUTION=$1
NAME=$2
SVNBRANCHUPSTREAM=$3
SVNBRANCHDEBIAN=$4

# We create 3 jobs:
# llvm-toolchain-precise-google-stable-binaries
# llvm-toolchain-precise-google-stable-source-trigger
# llvm-toolchain-precise-google-stable-source


if test "$DISTRIBUTION" = unstable; then
	JOBNAME="llvm-toolchain-$NAME"
else
	if test "$NAME" = snapshot; then
		# For a new ubuntu distro
                JOBNAME="llvm-toolchain-$DISTRIBUTION"
		SVNBRANCHUPSTREAM=""
	else
		JOBNAME="llvm-toolchain-$DISTRIBUTION-$NAME"
	fi
fi
JOBNAME_SOURCE=$JOBNAME"-source"
JOBNAME_SOURCE_TEMPLATE="source-template.xml"
JOBNAME_BINARY=$JOBNAME"-binaries"
JOBNAME_BINARY_TEMPLATE="binary-template.xml"

JOBNAME_TRIGGER=$JOBNAME"-source-trigger"
JOBNAME_TRIGGER_TEMPLATE="trigger-template.xml"



# create the directories
mkdir -p $JOBNAME_SOURCE
mkdir -p $JOBNAME_BINARY
mkdir -p $JOBNAME_TRIGGER
mkdir -p /srv/repository/$DISTRIBUTION
chown jenkins. /srv/repository/$DISTRIBUTION

sed -e "s|@NAME@|$JOBNAME_TRIGGER|g" -e "s|@NAME_SOURCE@|$JOBNAME_SOURCE|g" -e "s|@BRANCH@|$SVNBRANCHUPSTREAM|g" $JOBNAME_TRIGGER_TEMPLATE > $JOBNAME_TRIGGER/config.xml

sed -e "s|@NAME_BINARY@|$JOBNAME_BINARY|g" -e "s|@BRANCH@|$SVNBRANCHUPSTREAM|g" -e "s|@DISTRIBUTION@|$DISTRIBUTION|g" -e "s|@BRANCH_DEBIAN@|$SVNBRANCHDEBIAN|g" $JOBNAME_SOURCE_TEMPLATE > $JOBNAME_SOURCE/config.xml

sed -e "s|@NAME_SOURCE@|$JOBNAME_SOURCE|g" -e "s|@NAME@|$JOBNAME_BINARY|g" -e "s|@JOBNAME@|$JOBNAME|g" -e "s|@BRANCH@|$SVNBRANCHUPSTREAM|g" -e "s|@DISTRIBUTION@|$DISTRIBUTION|g" $JOBNAME_BINARY_TEMPLATE > $JOBNAME_BINARY/config.xml

chown -R jenkins.nogroup $JOBNAME_SOURCE $JOBNAME_BINARY $JOBNAME_TRIGGER

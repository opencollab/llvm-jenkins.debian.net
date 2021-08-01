#!/bin/bash
# sh create-new-job.sh precise 3.5 release_35 3.5
# sh create-new-job.sh unstable 3.5 release_35 3.5
# sh create-new-job.sh waly snapshot snapshot snapshot

if test $# -ne 4; then
    echo "Syntax:"
    echo "$0 distribution name GITbranch_upstream GITbranch_debian"
    exit 1
fi

DISTRIBUTION=$1
NAME=$2
GITBRANCHUPSTREAM=$3
GITBRANCHDEBIAN=$4

# We create 3 jobs:
# llvm-toolchain-precise-stable-binaries
# llvm-toolchain-precise-stable-source-trigger
# llvm-toolchain-precise-stable-source


if test "$DISTRIBUTION" = unstable; then
	JOBNAME="llvm-toolchain-$NAME"
else
	if test "$NAME" = snapshot; then
		# For a new ubuntu distro
                JOBNAME="llvm-toolchain-$DISTRIBUTION"
		GITBRANCHUPSTREAM=""
	else
		JOBNAME="llvm-toolchain-$DISTRIBUTION-$NAME"
	fi
fi
JOBNAME_SOURCE=$JOBNAME"-source"
JOBNAME_SOURCE_TEMPLATE="source-template.xml"
JOBNAME_BINARY=$JOBNAME"-binaries"
JOBNAME_BINARY_TEMPLATE="binary-template.xml"
JOBNAME_BINARY_SYNC=$JOBNAME"-binaries-sync"
JOBNAME_BINARY_SYNC_TEMPLATE="binary-sync-template.xml"


JOBNAME_TRIGGER=$JOBNAME"-source-trigger"
JOBNAME_TRIGGER_TEMPLATE="trigger-template.xml"

# ex: llvm-toolchain-binaries-12-integration-test
JOBNAME_INTEGRATION_TEST=$JOBNAME"-integration-test"
JOBNAME_INTEGRATION_TEST_TEMPLATE="integration-test-template.xml"


# create the directories
mkdir -p $JOBNAME_SOURCE
mkdir -p $JOBNAME_BINARY
mkdir -p $JOBNAME_INTEGRATION_TEST
if test "$NAME" = snapshot; then
	mkdir -p $JOBNAME_BINARY_SYNC
fi

mkdir -p $JOBNAME_TRIGGER
mkdir -p /srv/repository/$DISTRIBUTION
chown jenkins. /srv/repository/$DISTRIBUTION

sed -e "s|@NAME@|$JOBNAME_TRIGGER|g" -e "s|@NAME_SOURCE@|$JOBNAME_SOURCE|g" -e "s|@BRANCH@|$GITBRANCHUPSTREAM|g" -e "s|@BRANCH_DEBIAN@|$GITBRANCHDEBIAN|g" $JOBNAME_TRIGGER_TEMPLATE > $JOBNAME_TRIGGER/config.xml

sed -e "s|@NAME_BINARY@|$JOBNAME_BINARY|g" -e "s|@BRANCH@|$GITBRANCHUPSTREAM|g" -e "s|@DISTRIBUTION@|$DISTRIBUTION|g" -e "s|@BRANCH_DEBIAN@|$GITBRANCHDEBIAN|g" $JOBNAME_SOURCE_TEMPLATE > $JOBNAME_SOURCE/config.xml

sed -e "s|@NAME_SOURCE@|$JOBNAME_SOURCE|g" -e "s|@NAME@|$JOBNAME_BINARY|g" -e "s|@JOBNAME@|$JOBNAME|g" -e "s|@BRANCH@|$GITBRANCHUPSTREAM|g" -e "s|@DISTRIBUTION@|$DISTRIBUTION|g" $JOBNAME_BINARY_TEMPLATE > $JOBNAME_BINARY/config.xml

sed -e "s|@DISTRIBUTION@|$DISTRIBUTION|g" $JOBNAME_INTEGRATION_TEST_TEMPLATE > $JOBNAME_INTEGRATION_TEST/config.xml

if test "$NAME" = snapshot; then
	sed -e "s|@DISTRIBUTION@|$DISTRIBUTION|g" $JOBNAME_BINARY_SYNC_TEMPLATE > $JOBNAME_BINARY_SYNC/config.xml
fi

chown -R jenkins.nogroup $JOBNAME_SOURCE $JOBNAME_BINARY $JOBNAME_TRIGGER $JOBNAME_INTEGRATION_TEST

if test "$NAME" = snapshot; then
	chown -R jenkins.nogroup $JOBNAME_BINARY_SYNC
fi

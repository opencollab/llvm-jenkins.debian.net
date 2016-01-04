#!/bin/bash
# sh create-new-job-default.sh precise

if test $# -ne 1; then
    echo "Syntax:"
    echo "$0 distribution"
    exit 1
fi

DISTRIBUTION=$1

# We create 2 jobs:
# llvm-defaults-binaries
# llvm-defaults-source

JOBNAME="llvm-defaults-$DISTRIBUTION"

JOBNAME_SOURCE=$JOBNAME"-source"
JOBNAME_SOURCE_TEMPLATE="source-defaults-template.xml"
JOBNAME_BINARY=$JOBNAME"-binaries"
JOBNAME_BINARY_TEMPLATE="binary-defaults-template.xml"


# create the directories
mkdir -p $JOBNAME_SOURCE
mkdir -p $JOBNAME_BINARY
mkdir -p /srv/repository/$DISTRIBUTION
chown jenkins. /srv/repository/$DISTRIBUTION

sed  -e "s|@DISTRIBUTION@|$DISTRIBUTION|g"  $JOBNAME_SOURCE_TEMPLATE > $JOBNAME_SOURCE/config.xml

sed -e "s|@DISTRIBUTION@|$DISTRIBUTION|g" $JOBNAME_BINARY_TEMPLATE > $JOBNAME_BINARY/config.xml

chown -R jenkins.nogroup $JOBNAME_SOURCE $JOBNAME_BINARY
#!/bin/bash
VERSION="3.7"
VERSION_2="37"
DISTROS=( unstable jessie precise trusty utopic vivid )
for d in "${DISTROS[@]}"
do
	echo $d
	sh create-new-job.sh $d $VERSION release_$VERSION_2 $VERSION
# sh create-new-job.sh unstable 3.5 release_35 3.5
done

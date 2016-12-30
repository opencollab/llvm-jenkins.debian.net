#!/bin/bash
VERSION="3.9"
VERSION_2="39"
DISTROS=( unstable jessie precise trusty wily xenial yakkety )
for d in "${DISTROS[@]}"
do
	echo $d
	sh create-new-job.sh $d $VERSION release_$VERSION_2 $VERSION
# sh create-new-job.sh unstable 3.5 release_35 3.5
done

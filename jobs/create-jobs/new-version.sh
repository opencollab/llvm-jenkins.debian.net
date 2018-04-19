#!/bin/bash
VERSION="6.0"
VERSION_2="60"
DISTROS=( unstable jessie stretch trusty xenial yakkety zesty artful)
for d in "${DISTROS[@]}"
do
	echo $d
	sh create-new-job.sh $d $VERSION release_$VERSION_2 $VERSION
# sh create-new-job.sh unstable 3.5 release_35 3.5
	if test "$d" == "unstable"; then
		d=""
	else
		d="-$d"
	fi
	echo "sed -i -e 's|llvm-toolchain$d-binaries,|llvm-toolchain$d-binaries, llvm-toolchain$d-$VERSION-binaries,|' ../llvm-toolchain$d-binaries-sync/config.xml"
done
echo "update the sync job to upload the version"

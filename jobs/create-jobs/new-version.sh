#!/bin/bash
VERSION="14"
VERSION_2="140"
DISTROS=( stretch unstable buster bullseye bionic focal groovy hirsute impish )
for d in "${DISTROS[@]}"
do
	echo $d
	sh create-new-job.sh $d $VERSION release/$VERSION.x $VERSION
# sh create-new-job.sh unstable 3.5 release_35 3.5
	if test "$d" == "unstable"; then
		d=""
	else
		d="-$d"
	fi
	echo "sed -i -e 's|llvm-toolchain$d-binaries,|llvm-toolchain$d-binaries, llvm-toolchain$d-$VERSION-binaries,|' ../llvm-toolchain$d-binaries-sync/config.xml"
done
echo "update the sync job to upload the version (by hand in the interface)"
echo "Disable i386 on recent versions of Ubuntu"
echo "Disable the old version when ready"
echo "emacs /srv/repository/*/conf/distributions to add the new version"
echo "Update test-install.sh"
echo "Update https://github.com/opencollab/llvm-toolchain-integration-test-suite/edit/main/.github/workflows/CI.yml"

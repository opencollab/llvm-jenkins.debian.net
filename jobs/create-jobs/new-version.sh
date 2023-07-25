#!/bin/bash
VERSION="17"
VERSION_2="170"
DISTROS=( unstable buster bullseye bookworm bionic focal lunar jammy kinetic )
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
D=$(echo "{$DISTROS}"| sed -e "s| |,|g")
echo "emacs /srv/repository/$D/conf/distributions to add the new version"
echo "do it also on arm64 & s390x machines"
echo "Update test-install.sh & update the master node"
echo "Update llvm.sh"
echo "Update https://github.com/opencollab/llvm-toolchain-integration-test-suite/edit/main/.github/workflows/CI.yml"
echo "You can also disable the previous version with:"
cat << EOF
import hudson.model.*

jenkins = Hudson.instance
jenkins.instance.getView("13").items.each { item ->
    println "\nJob: $item.name"
    item.disabled = true
}
EOF

echo "in https://llvm-jenkins.debian.net/script"

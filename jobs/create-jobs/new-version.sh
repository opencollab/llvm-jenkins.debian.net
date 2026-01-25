#!/bin/bash
VERSION="21"
VERSION_2="210"
DEB=( unstable buster bullseye bookworm )
UBUNTU=( focal jammy noble oracular plucky )
DISTROS=( "${DEB[@]}" "${UBUNTU[@]}" )
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
echo "update the sync job to upload the version (by hand in the interface) - links at the end"
echo "Disable i386 on recent versions of Ubuntu"
echo "Make sure that the label on Debian is set for i386"
echo "Disable the old version when ready"
D=$(echo "{$DISTROS}"| sed -e "s| |,|g")
echo "do it also on arm64 & s390x machines"
echo "Update test-install.sh & update the build node (image-update.sh)"
echo "Update llvm.sh"
echo "Update https://github.com/opencollab/llvm-toolchain-integration-test-suite/edit/main/.github/workflows/CI.yml"
echo "edit https://github.com/opencollab/llvm-jenkins.debian.net/blob/master/install-tests/test.sh to add the new version"
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

for d in "${DISTROS[@]}"
do
    # sh create-new-job.sh unstable 3.5 release_35 3.5
    if test "$d" == "unstable"; then
        d=""
    else
        d="-$d"
    fi
    echo "https://llvm-jenkins.debian.net/view/sync/job/llvm-toolchain$d-binaries-sync/configure"
done


for d in "${DISTROS[@]}"; do
    ARCH="amd64 source s390x arm64"

    # Check if $d is in DEB
    for deb_distro in "${DEB[@]}"; do
        if [[ "$d" == "$deb_distro" ]]; then
            ARCH="amd64 i386 source s390x arm64"
            break
        fi
    done
    if test "$d" == "unstable"; then
        n=""
    else
        n="-$d"
    fi
    if ! grep -q llvm-toolchain$n-$VERSION /srv/repository/$d/conf/distributions; then
	echo "
Codename: llvm-toolchain$n-$VERSION
Architectures: $ARCH
Components: main
UDebComponents: main
Tracking: minimal
SignWith: 6084F3CF814B57C1CF12EFD515CF4D18AF4F7421
" >> /srv/repository/$d/conf/distributions
    fi
done

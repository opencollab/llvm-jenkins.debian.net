#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
NAME="noble"

IS_UBUNTU=1

VERSIONS=(17 18 snapshot)
for v in "${VERSIONS[@]}"
do
        echo $v
        v_without_dot=$(echo $v|sed -e "s|\.||g")
        sh create-new-job.sh $NAME $v release/$v_without_dot $v
        chown -R jenkins. llvm-toolchain-*
	if test $IS_UBUNTU -eq 1; then
	    sed -i "/<string>i386<\/string>/d" llvm-toolchain-*/config.xml
	fi
done

sh create-new-job-default.sh $NAME

cd /usr/share/debootstrap/scripts
echo "Make sure that the version for  /usr/share/debootstrap/scripts is correct"
echo "EDIT ME to verify"
ln -s trusty $NAME
cd -

mkdir  -p /srv/repository/$NAME
chown jenkins. /srv/repository/$NAME

cd ~jenkins/llvm-jenkins.debian.net.git/
sed -i "s/UBUNTU_SUITES=(/UBUNTU_SUITES=(\"$NAME\" /" pbuilderrc
git commit -m "add $NAME in pbuilderrc" pbuilderrc
sed -i -e 's/\(DISTRO=".*\)"/\1 $NAME"/' test-install.sh
git commit -m "add $NAME in test-install.sh" test-install.sh
ed -i -e 's/\(UBUNTU_DISTRO=".*\)"/\1 $NAME"/' create-refresh-image.sh
it commit -m "add $NAME in create-refresh-image.sh" create-refresh-image.sh
cd -

rm -rf llvm-toolchain-$NAME-source-trigger
sed -i -e 's|  <triggers/>|  <triggers>\n    <hudson.triggers.TimerTrigger>\n      <spec>H 8,20 * * *</spec>\n    </hudson.triggers.TimerTrigger>\n  </triggers>|' llvm-toolchain-$NAME-source/config.xml

sed -i -e "s|@STABLE@|${VERSIONS[0]}|" -e "s|@DEV@|${VERSIONS[1]}|" llvm-toolchain-$NAME-binaries-sync/config.xml

sed -i -e "s|release/${VERSIONS[0]}|release/${VERSIONS[0]}.x|" llvm-toolchain-$NAME-${VERSIONS[0]}-source/config.xml
sed -i -e "s|release/${VERSIONS[1]}|release/${VERSIONS[1]}.x|" llvm-toolchain-$NAME-${VERSIONS[1]}-source/config.xml

echo "Add the new version in /srv/salt/llvm-slave.sls on cocoro for /usr/share/debootstrap/scripts"
echo "run with salt 'llvm*' state.apply"
echo "OR on llvm-jenkins, run update-all.sh"
echo "run the command on pulau"
echo "run the following commands":
echo "PREVIOUS=UPDATE"
echo "cp -R /srv/repository/\$PREVIOUS/conf /srv/repository/$NAME/conf/"
echo "sed -i -e 's|\$PREVIOUS|$NAME|g' /srv/repository/$NAME/conf/distributions"
echo "ssh jenkins@cb0dd220.packethost.net mkdir -p /srv/repository/$NAME/conf/"
echo "ssh llvm-jenkins-s390x-1.debian.net mkdir -p /srv/repository/$NAME/conf/"
echo "scp /srv/repository/$NAME/conf/distributions jenkins@cb0dd220.packethost.net:/srv/repository/$NAME/conf/distributions"
echo "scp /srv/repository/$NAME/conf/distributions llvm-jenkins-s390x-1.debian.net:/srv/repository/kinetic/conf/distributions"
echo "Run image-update.sh on your system"
echo "create the filter view"
echo "start the jobs in jenkins"

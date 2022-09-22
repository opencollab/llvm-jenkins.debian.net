#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
NAME="kinetic"

VERSIONS=(14 15 snapshot)
for v in "${VERSIONS[@]}"
do
        echo $v
        v_without_dot=$(echo $v|sed -e "s|\.||g")
        sh create-new-job.sh $NAME $v release/$v_without_dot $v
        chown -R jenkins. llvm-toolchain-*
done

sh create-new-job-default.sh $NAME

cd /usr/share/debootstrap/scripts
echo "Make sure that the version for  /usr/share/debootstrap/scripts is correct"
echo "EDIT ME to verify"
ln -s trusty $NAME

mkdir  -p /srv/repository/$NAME
chown jenkins. /srv/repository/$NAME

emacs ~jenkins/llvm-jenkins.debian.net.git/pbuilderrc
echo "commit ~jenkins/pbuilderrc"
echo "On every slave, git pull + create the symlink from $NAME for deboostrap"
echo "including other archs"
echo "remove i386 in case of ubuntu distro"
echo "also delete llvm-toolchain-$NAME-source-trigger and update the cron in the job"
echo "Add the new version in /srv/salt/llvm-slave.sls on cocoro for /usr/share/debootstrap/scripts"
echo "Update llvm-toolchain-$NAME-binaries-sync to fix the version to sync"
echo "Update the update of the build in the main job llvm-toolchain-$NAME-source"
echo "Update the version (not snapshot) to add the .x of the branch name in the orig-tar.sh script (ex: release/12.x instead of release/12)"
echo "in /srv/repository/$NAME/conf/* maybe copy the configuration from other repo to avoid s390x issues"
echo "ex: cp /srv/repository/jammy/conf/distributions /srv/repository/$NAME/conf/"
echo "create srv/repository/$NAME/conf/distributions on arm64 & s390x:"
echo "ssh jenkins@cb0dd220.packethost.net mkdir -p /srv/repository/$NAME/conf/"
echo "ssh llvm-jenkins-s390x-1.debian.net mkdir -p /srv/repository/$NAME/conf/"
echo "scp /srv/repository/$NAME/conf/distributions jenkins@cb0dd220.packethost.net:/srv/repository/$NAME/conf/distributions"
echo "scp /srv/repository/$NAME/conf/distributions llvm-jenkins-s390x-1.debian.net:/srv/repository/kinetic/conf/distributions"
echo "Run image-update.sh"
echo "create the filter view"
echo "start the jobs in jenkins"
echo "add it into test-install.sh"

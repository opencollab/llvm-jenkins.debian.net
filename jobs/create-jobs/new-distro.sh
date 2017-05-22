>#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
NAME="artful"

VERSIONS=( 3.9 4.0 snapshot)
for v in "${VERSIONS[@]}"
do
        echo $v
        v_without_dot=$(echo $v|sed -e "s|\.||g")
        sh create-new-job.sh $NAME $v release_$v_without_dot $v
        chown -R jenkins. llvm-toolchain-*
done

cd /usr/share/debootstrap/scripts
ln -s trusty $NAME

mkdir  -p /srv/repository/$NAME
chown jenkins. /srv/repository/$NAME

emacs ~/.pbuilderrc
echo "On every slave, git pull + create the symlink from $NAME for deboostrap"
echo "also ignore the new distro in pbuilder-hookdir/D23-add-repo-for-default"
echo "Please also create llvm-defaults-$NAME"

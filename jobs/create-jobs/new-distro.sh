#!/bin/bash
NAME="wily"

VERSIONS=( 3.6 3.7 snapshot)
for v in "${VERSIONS[@]}"
do
	echo $v
	v_without_dot=$(echo $v|sed -e "s|\.||g")
	echo $v_without_dot
echo	sh create-new-job.sh $NAME $v release_$v_without_dot $v
# sh create-new-job.sh unstable 3.5 release_35 3.5
done

cd /usr/share/debootstrap/scripts
ln -s trusty $NAME

mkdir /srv/repository/$NAME
chown jenkins. $NAME

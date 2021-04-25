#!/bin/bash
set -e

DISTRO="buster bullseye unstable bionic focal groovy hirsute"
VERSION="9 10 11 12"

for d in $DISTRO; do
	if test ! -d $d.chroot; then
		sudo debootstrap $d $d.chroot
	fi
	if test ! -e $0.chroot/proc/uptime; then
		sudo mount -t proc /proc $d.chroot/proc || true
	fi
done

TEMPLATE="deb http://apt.llvm.org/@DISTRO_PATH@/ llvm-toolchain@DISTRO@ main"
TEMPLATE_VERSION="deb http://apt.llvm.org/@DISTRO_PATH@/ llvm-toolchain@DISTRO@-@VERSION@ main"

for d in $DISTRO; do
	echo "" > $d.list
	if test "$d" != "unstable"; then
		echo $TEMPLATE|sed -e "s|@DISTRO@|-$d|g" -e "s|@DISTRO_PATH@|$d|g" >> $d.list
	else
                echo $TEMPLATE|sed -e "s|@DISTRO@||g" -e "s|@DISTRO_PATH@|$d|g" >> $d.list
     fi
     if test "$d" == "focal" -o "$d" == "groovy" -o "$d" == "hirsute"; then
          # focal & groovy need universe
        if test "$(arch)" == "s390x"; then
            echo "deb http://ports.ubuntu.com/ubuntu-ports $d universe" >> $d.list
        else
            echo "deb http://www-ftp.lip6.fr/pub/linux/distributions/Ubuntu/ $d universe"  >> $d.list
        fi
     fi
     for v in $VERSION; do
          if test $v == "9" -o $v == "10"; then
               if test "$d" == bullseye; then
                    continue
               fi
          fi
                if test $v == "9" -a $d == "groovy"; then
                        continue
                fi
                if test $v == "9" -a $d == "hirsute"; then
                        continue
                fi

	        if test "$d" != "unstable"; then
			echo $TEMPLATE_VERSION|sed -e "s|@DISTRO@|-$d|g" -e "s|@DISTRO_PATH@|$d|g" -e "s|@VERSION@|$v|g" >> $d.list
		else
                        echo $TEMPLATE_VERSION|sed -e "s|@DISTRO@||g" -e "s|@DISTRO_PATH@|$d|g" -e "s|@VERSION@|$v|g" >> $d.list
		fi
	done
	sudo cp $d.list $d.chroot/etc/apt/sources.list.d/clang.list

	echo "
	Package: *
	Pin: origin apt.llvm.org
	Pin-Priority: 1000" > $d.pref
	sudo cp $d.pref /etc/apt/preferences.d/local-pin-900
done
VERSION="$VERSION 13"
for d in $DISTRO; do
	echo "========= Install on $d"
	PKG=""
	CMD=""
        for v in $VERSION; do
                if test $v == "9" -o $v == "10"; then
                        if test "$d" == bullseye; then
                                continue
                        fi
                fi
                if test $v == "9" -a $d == "groovy"; then
                        continue
                fi
                if test $v == "9" -a $d == "hirsute"; then
                        continue
                fi

		PKG="$PKG clang-$v"
		CMD="clang-$v --version; $CMD"
	done
	echo "
	set -e
	apt install -y wget gnupg
	wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add -
	apt update
	apt install -y $PKG --no-install-recommends
	$CMD
#	apt --purge remove -y $PKG
#	apt -y autoremove
	" > $d-script.sh
	sudo cp $d-script.sh $d.chroot/root/install.sh
	sudo chroot $d.chroot/ /bin/bash -c "bash /root/install.sh"
done


#!/bin/sh

set -e -v
d=$1
architecture=$2
PATH_CHROOT=$d.chroot.$architecture

MIRROR=""
if test "$d" == "buster" -o "$d" == "bullseye" -o "$d" == "unstable"; then
    # deb.debian.org is failing too often
    MIRROR=http://cloudfront.debian.net/debian
fi

if test ! -d $PATH_CHROOT; then
        echo "Create $PATH_CHROOT chroot"
        debootstrap --arch $architecture $d $PATH_CHROOT $MIRROR
fi
if test ! -e $PATH_CHROOT/proc/uptime; then
        mount -t proc /proc $PATH_CHROOT/proc || true
fi
if test ! -e $PATH_CHROOT/dev/shm; then
        mount --bind /dev/shm "$PATH_CHROOT/dev/shm" || true
fi
if test ! -e $PATH_CHROOT/dev/pts; then
        mount --bind /dev/pts "$PATH_CHROOT/dev/pts" || true
fi

cat > $PATH_CHROOT/root/run.sh <<GLOBALEOF
#!/bin/bash
set -v

cd /root/
export PATH=/usr/lib/go-1.16/bin/:$PATH
export GOPATH=~/go/
rm -rf /rekor-cli rekor-cli $GOPATH

apt install -y golang-1.16-go git make

git clone https://github.com/sigstore/rekor.git rekor-cli
cd rekor-cli

make rekor-cli
strip rekor-cli
GLOBALEOF

chroot $PATH_CHROOT/ bash ./root/run.sh

cp $PATH_CHROOT/root/rekor-cli/rekor-cli rekor
ls -al rekor
file rekor
if test $architecture != "i386"; then
    # Don't run it on i386 as it runs on amd64
    ./rekor version
fi

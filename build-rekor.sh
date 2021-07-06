#!/bin/sh

d=$1
PATH_CHROOT=$d.chroot

if test ! -d $d.chroot; then
        echo "Create $d chroot"
        debootstrap $d $d.chroot
fi
if test ! -e $0.chroot/proc/uptime; then
        mount -t proc /proc $d.chroot/proc || true
fi
if test ! -e $0.chroot/dev/shm; then
        mount --bind /dev/shm "$d.chroot/dev/shm" || true
fi
if test ! -e $0.chroot/dev/pts; then
        mount --bind /dev/pts "$d.chroot/dev/pts" || true
fi

if test ! -d $d.chroot; then
	echo "chroot $PATH_CHROOT not found"
    exit 1
fi

cat > $d.chroot/root/run.sh <<GLOBALEOF
set -e
set -v

apt install -y golang git
go get -u -t -v github.com/sigstore/rekor/cmd/rekor-cli
cd $GOPATH/src/github.com/sigstore/rekor/cmd/rekor-cli
go build -v -o rekor
cp rekor /usr/local/bin/
GLOBALEOF

chroot $PATH_CHROOT/ bash ./root/run.sh

cp $d.chroot/root/go/src/github.com/sigstore/rekor/cmd/rekor-cli/rekor .
./rekor version

#!/bin/sh

set -e -v
d=$1
architecture=$2
PATH_CHROOT=$d.chroot.$architecture

if test ! -d $PATH_CHROOT; then
        echo "Create $PATH_CHROOT chroot"
        debootstrap --arch $architecture $d $PATH_CHROOT
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

export GOPATH=~/go/
rm -rf rekor-cli $GOPATH

apt install -y golang git

git clone https://github.com/sigstore/rekor.git rekor-cli

go get -u -t -v github.com/sigstore/rekor/cmd/rekor-cli
cd \$GOPATH/src/github.com/sigstore/rekor/cmd/rekor-cli
go build -v -o rekor
strip /root/go/src/github.com/sigstore/rekor/cmd/rekor-cli/rekor
GLOBALEOF

chroot $PATH_CHROOT/ bash ./root/run.sh

cp $PATH_CHROOT/root/go/src/github.com/sigstore/rekor/cmd/rekor-cli/rekor .
./rekor version

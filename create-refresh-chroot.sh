ARCHS="amd64 i386"
DEBIAN_DISTRO="buster bullseye unstable"
UBUNTU_DISTRO="bionic focal groovy hirsute impish"
cat > configfile  <<EOF
COMPONENTS="main universe"
EOF

for d in $DEBIAN_DISTRO; do
    for a in $ARCHS; do
        echo $a
        echo $d
        if test -d /var/cache/pbuilder/base-$d-$a.cow; then
            sudo DIST=$d ARCH=$a cowbuilder --update --basepath /var/cache/pbuilder/base-$d-$a.cow
        else
            sudo DIST=$d ARCH=$a cowbuilder --create --basepath /var/cache/pbuilder/base-$d-$a.cow --distribution $d --debootstrap debootstrap --mirror http://cloudfront.debian.net//debian/ --architecture $a --debootstrapopts --arch --debootstrapopts amd64 --debootstrapopts --variant=buildd --hookdir /usr/share/jenkins-debian-glue/pbuilder-hookdir/
        fi
    done
done

for d in $UBUNTU_DISTRO; do
    echo $d
    a=amd64
    if test -d /var/cache/pbuilder/base-$d-$a.cow; then
        sudo DIST=$d ARCH=$a cowbuilder --update --basepath /var/cache/pbuilder/base-$d-$a.cow
    else
        sudo DIST=$d ARCH=$a cowbuilder --create --basepath /var/cache/pbuilder/base-$d-$a.cow --distribution $d --debootstrap debootstrap --architecture $a --debootstrapopts --arch --debootstrapopts amd64 --debootstrapopts --variant=buildd --configfile=configfile --hookdir /usr/share/jenkins-debian-glue/pbuilder-hookdir/
    fi
done

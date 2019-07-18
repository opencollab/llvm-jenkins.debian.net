#!/bin/bash
set -eux

DISTRO=$(lsb_release -a | grep "Distributor ID" | awk '{print $3}')
VERSION=$(lsb_release -a | grep Release | awk '{print $2}')

# TODO: check if we run as root

case "${DISTRO}_${VERSION}" in
Debian_9.9 )
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - ;\
    add-apt-repository 'deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch-8 main' ;\
    apt-get update ;\
    apt-get install -y clang-8 lldb-8 lld-8
    ;;
* )
    echo "Distribution $DISTRO $VERSION is not supported"
    exit -1
    ;;
esac
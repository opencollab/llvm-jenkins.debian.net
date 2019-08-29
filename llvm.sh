#!/bin/bash
################################################################################
# Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
################################################################################
#
# This script will install the llvm toolchain on the different 
# Debian and Ubuntu versions

set -eux

# read optional command line argument
LLVM_VERSION=9
if [ "$#" -eq 1 ]; then
    LLVM_VERSION=$1
fi

DISTRO=$(lsb_release -a | grep "Distributor ID" | awk '{print $3}')
VERSION=$(lsb_release -a | grep Release | awk '{print $2}')
DIST_VERSION="${DISTRO}_${VERSION}"

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root!" 
   exit 1
fi

declare -A LLVM_VERSION_PATTERNS
LLVM_VERSION_PATTERNS[8]="-8"
LLVM_VERSION_PATTERNS[9]="-9"
LLVM_VERSION_PATTERNS[10]=""

if [ ! ${LLVM_VERSION_PATTERNS[$LLVM_VERSION]+_} ]; then
    echo "This script does not support LLVM version $LLVM_VERSION"
    exit 3
fi

LLVM_VERSION_STRING=${LLVM_VERSION_PATTERNS[$LLVM_VERSION]}

# find the right add-apt-repository arguments for the distros
declare -A APT_REPOS
APT_REPOS["Debian_9.9"]="deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch$LLVM_VERSION_STRING main"
APT_REPOS["Debian_10"]="deb http://apt.llvm.org/buster/ llvm-toolchain-buster$LLVM_VERSION_STRING main"
APT_REPOS["Debian_unstable"]="deb http://apt.llvm.org/unstable/ llvm-toolchain$LLVM_VERSION_STRING main"
APT_REPOS["Ubuntu_16.04"]="deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial$LLVM_VERSION_STRING main"
APT_REPOS["Ubuntu_18.04"]="deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic$LLVM_VERSION_STRING main"
APT_REPOS["Ubuntu_18.10"]="deb http://apt.llvm.org/cosmic/ llvm-toolchain-cosmic$LLVM_VERSION_STRING main"
APT_REPOS["Ubuntu_19.04"]="deb http://apt.llvm.org/disco/ llvm-toolchain-disco$LLVM_VERSION_STRING main"


if [ ! ${APT_REPOS[$DIST_VERSION]+_} ]; then
    echo "Distribution '$DISTRO' in version '$VERSION' is not supported by this script."
    exit 2
fi

# install everything
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
add-apt-repository "${APT_REPOS[$DIST_VERSION]}"
apt-get update 
apt-get install -y clang-$LLVM_VERSION lldb-$LLVM_VERSION lld-$LLVM_VERSION clangd-$LLVM_VERSION

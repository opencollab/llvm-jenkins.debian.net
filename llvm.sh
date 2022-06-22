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

# helper function to add symbolic link to an executable
# NOTE: this will NOT replace the executable that was added by installation from official APT
symlink_llvm() {
    local executable=$1

    # if executable was installed
    if [[ -f /usr/lib/llvm-${LLVM_VERSION}/bin/${executable} ]]; then
        if [[ ! -f /usr/bin/${executable} ]]; then
            # add executable globally if there is none
            ln -s /usr/lib/llvm-${LLVM_VERSION}/bin/${executable} /usr/bin/${executable}
        fi
    fi
}

CURRENT_LLVM_STABLE=14

# Check for required tools
needed_binaries=(lsb_release wget add-apt-repository gpg)
missing_binaries=()
for binary in "${needed_binaries[@]}"; do
    if ! which $binary &>/dev/null ; then
        missing_binaries+=($binary)
    fi
done
if [[ ${#missing_binaries[@]} -gt 0 ]] ; then
    echo "You are missing some tools this script requires: ${missing_binaries[@]}"
    echo "(hint: apt install lsb-release wget software-properties-common gnupg)"
    exit 4
fi

# read optional command line argument
# We default to the current stable branch of LLVM
LLVM_VERSION=$CURRENT_LLVM_STABLE
ALL=0
if [ "$#" -ge 1 ]; then
    LLVM_VERSION=$1
    if [ "$1" == "all" ]; then
        # special case for ./llvm.sh all
        LLVM_VERSION=$CURRENT_LLVM_STABLE
        ALL=1
    fi
    if [ "$#" -ge 2 ]; then
      if [ "$2" == "all" ]; then
          # Install all packages
          ALL=1
      fi
    fi
fi

DISTRO=$(lsb_release -is)
VERSION=$(lsb_release -sr)

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root!"
   exit 1
fi

declare -A LLVM_VERSION_PATTERNS
LLVM_VERSION_PATTERNS[9]="-9"
LLVM_VERSION_PATTERNS[10]="-10"
LLVM_VERSION_PATTERNS[11]="-11"
LLVM_VERSION_PATTERNS[12]="-12"
LLVM_VERSION_PATTERNS[13]="-13"
LLVM_VERSION_PATTERNS[14]="-14"
LLVM_VERSION_PATTERNS[15]=""

if [ ! ${LLVM_VERSION_PATTERNS[$LLVM_VERSION]+_} ]; then
    echo "This script does not support LLVM version $LLVM_VERSION"
    exit 3
fi

LLVM_VERSION_STRING=${LLVM_VERSION_PATTERNS[$LLVM_VERSION]}

# obtain VERSION_CODENAME and UBUNTU_CODENAME (for Ubuntu and its derivatives)
source /etc/os-release
DISTRO=${DISTRO,,}
case ${DISTRO} in
    debian)
        if [[ "${VERSION}" == "unstable" ]] || [[ "${VERSION}" == "testing" ]]; then
            CODENAME=unstable
            LINKNAME=
        else
            # "stable" Debian release
            CODENAME=${VERSION_CODENAME}
            LINKNAME=-${CODENAME}
        fi
        ;;
    *)
        # ubuntu and its derivatives
        if [[ -n `uname -v | grep -i ubuntu` ]]; then
            CODENAME=${UBUNTU_CODENAME}
            if [[ -n "${CODENAME}" ]]; then
                LINKNAME=-${CODENAME}
            fi
        fi
        ;;
esac

# join the repository name
if [[ -n "${CODENAME}" ]]; then
    REPO_NAME="deb http://apt.llvm.org/${CODENAME}/  llvm-toolchain${LINKNAME}${LLVM_VERSION_STRING} main"

    # check if the repository exists for the distro and version
    if ! wget -q --method=HEAD http://apt.llvm.org/${CODENAME} &> /dev/null; then
        echo "Distribution '${DISTRO}' in version '${VERSION}' is not supported by this script."
        exit 2
    fi
fi


# install everything
if [[ -z "`apt-key list | grep -i llvm`" ]]; then
    # download GPG key once
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
fi
add-apt-repository "${REPO_NAME}"
apt-get update
PKG="clang-$LLVM_VERSION lldb-$LLVM_VERSION lld-$LLVM_VERSION clangd-$LLVM_VERSION"
if [[ $ALL -eq 1 ]]; then
    # same as in test-install.sh
    # No worries if we have dups
    PKG="$PKG clang-tidy-$LLVM_VERSION clang-format-$LLVM_VERSION clang-tools-$LLVM_VERSION llvm-$LLVM_VERSION-dev lld-$LLVM_VERSION lldb-$LLVM_VERSION llvm-$LLVM_VERSION-tools libomp-$LLVM_VERSION-dev libc++-$LLVM_VERSION-dev libc++abi-$LLVM_VERSION-dev libclang-common-$LLVM_VERSION-dev libclang-$LLVM_VERSION-dev libclang-cpp$LLVM_VERSION-dev libunwind-$LLVM_VERSION-dev"
fi
apt-get install -y $PKG

# add symbolic link(s) for a few installed packages
symlink_llvm clang
symlink_llvm clang++
symlink_llvm clangd
symlink_llvm clang-cpp
symlink_llvm clang-format
symlink_llvm clang-tidy
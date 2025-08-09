#!/bin/bash
#
# test the llvm.sh installation script for the different distros

# LLVM versions to be tested
LLVM_VERSIONS=(18 19 20 21 22)

# Linux distributions to be tested
# the distro names must match to the name of a docker image!
DISTROS=("debian:trixie" "debian:bookworm"  "debian:buster" "debian:bullseye"  "debian:testing" "debian:unstable" "ubuntu:20.04" "ubuntu:22.04" "ubuntu:24.04" "ubuntu:24.10" "ubuntu:25.10")

# file containing the test suite
TEST_SUITE=tests.bats
if [ -f $TEST_SUITE ] ; then
  rm -r $TEST_SUITE
fi

# include the helper script
echo "load test_helper" >> $TEST_SUITE
echo "" >> $TEST_SUITE

# generate the test suite for the product of DISTROS x LLVM_VERSIONS
for distro in "${DISTROS[@]}"
do
  for llvm_version in "${LLVM_VERSIONS[@]}"
    do
    # we skip the test for debian:trixie with llvm 16 since the installation is not working due to unmet dependencies
      if ! [[ ("${distro}" == "debian:trixie" || "${distro}" == "debian:testing" || "${distro}" == "debian:unstable") && "${llvm_version}" == "16" ]]; then
          echo "@test \"${distro} - llvm ${llvm_version}\" {" >> $TEST_SUITE
          echo "   build_run ${distro} ${llvm_version} " >> $TEST_SUITE
          echo "}" >> $TEST_SUITE
          echo "" >> $TEST_SUITE
      fi
    done
done

# prepare logfile
LOG_FILE=test.log
if [ -f $LOG_FILE ] ; then
  rm -r $LOG_FILE
fi


# run the test suite
bats/bin/bats $TEST_SUITE | tee $LOG_FILE

#!/bin/bash
#
# test the llvm.sh installation script for the different distros

# LLVM versions to be tested
LLVM_VERSIONS=(16 17 18)

# Linux distributions to be tested
# the distro names must match to the name of a docker image!
DISTROS=("debian:buster" "debian:bullseye" "debian:testing" "debian:unstable" "ubuntu:16.04" "ubuntu:18.04" "ubuntu:18.10" "ubuntu:19.04")

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
    echo "@test \"${distro} - llvm ${llvm_version}\" {" >> $TEST_SUITE
    echo "   build_run ${distro} ${llvm_version} " >> $TEST_SUITE
    echo "}" >> $TEST_SUITE
    echo "" >> $TEST_SUITE
  done
done

# prepare logfile
LOG_FILE=test.log
if [ -f $LOG_FILE ] ; then
  rm -r $LOG_FILE
fi


# run the test suite
bats/bin/bats $TEST_SUITE | tee $LOG_FILE

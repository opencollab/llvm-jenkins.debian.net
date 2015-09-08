#!/bin/sh
exit 0
export PATH=$PATH:/opt/cov-analysis/bin/
apt-get install clang-3.2 g++-4.8
cov-configure --compiler clang --comptype gcc
cov-configure --compiler gcc-4.8 --comptype gcc
cov-configure --compiler g++-4.8 --comptype gcc
apt-get --purge remove clang-3.2 g++-4.8

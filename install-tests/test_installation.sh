#!/bin/bash
# build a simple project with clang

set -eux
VERSION=$1

# bulid the demo project
cd /build/sample_project
export CC=clang-${VERSION}
make clean
make

# check the build project
RESULT=$(./hello_world)
if [ RESULT -ne "Hello World!\n" ]; then
    exit 1
fi

# check if clangd can be started
clangd-${VERSION} --version

echo Done!

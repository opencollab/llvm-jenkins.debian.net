#!/bin/bash
set -eux
VERSION=$1

echo "Building with clang version $($CC --version)..."
cd /build
cd protobuf
if [ -d "build" ]; then
rm -rf build
fi
mkdir -p build
cd build
export CXX=clang++-$VERSION
export CC=clang-$VERSION
cmake ../cmake -GNinja
ninja

echo Done!

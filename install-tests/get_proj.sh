#!/bin/bash
set -eux

git clone --depth 1 --single-branch --branch v3.7.1 https://github.com/protocolbuffers/protobuf.git
cd protobuf
git submodule update --init --recursive
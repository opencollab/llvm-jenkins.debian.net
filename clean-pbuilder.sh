#!/bin/bash

set -e

rm -rf $(find /var/cache/pbuilder/build/ -maxdepth 1 -cmin +240 -type d)
rm -rf $(find /var/cache/pbuilder/*/aptcache/ -ctime +7 -iname '*.deb')

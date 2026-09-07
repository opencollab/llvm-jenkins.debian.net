#!/bin/bash

set -e

# A cowbuilder run that died mid-way (2026-09-03: the base refresh failed on
# a missing /dev/ptmx) leaves /proc, /sys, /dev/pts ... mounted under its
# build/cow.N copy. rm -rf would descend into those mounts, so detach them
# first, deepest mount point first. N is the PID of the cowbuilder that owns
# the copy: leave it alone while that process is still around.
for cow in $(find /var/cache/pbuilder/build/ -maxdepth 1 -cmin +240 -type d -name 'cow.*'); do
    pid=${cow##*/cow.}
    [ -d "/proc/$pid" ] && continue
    for mnt in $(awk -v root="$cow" '$2 == root || index($2, root "/") == 1 { print $2 }' /proc/mounts | sort -r); do
        umount "$mnt" 2>/dev/null || umount -l "$mnt" || true
    done
done

rm -rf $(find /var/cache/pbuilder/build/ -maxdepth 1 -cmin +240 -type d)
rm -rf $(find /var/cache/pbuilder/*/aptcache/ -ctime +7 -iname '*.deb')

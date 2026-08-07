#!/bin/bash
# Unblock pbuilder builds wedged in their "umount: target is busy" retry loop.
#
# The in-chroot hooks (pbuilder-hookdir/B01sccache-stop, B99sccache-stop,
# C10shell) are the primary fix: they stop the sccache daemon that pins the
# /opt/sccache/ bind mount before pbuilder tries to unmount it. This script is
# the safety net for whatever slips past them -- pbuilder retries that umount
# *forever*, so a single missed process costs an entire build (on 2026-08-03 an
# s390x build sat in that loop for four hours after a successful compile).
#
# Detecting "wedged" without touching healthy builds
# --------------------------------------------------
# pbuilder tears the bind mounts down in a fixed order, and /opt/sccache/ comes
# *after* the ccache bind mount:
#
#     I: unmounting /var/cache/pbuilder/ccache filesystem
#     I: unmounting /tmp/apt-XXXXXX filesystem
#     I: unmounting /opt/sccache/ filesystem
#     W: Could not unmount /opt/sccache/: ... target is busy.   <-- loops here
#
# So a chroot where cow.N/opt/sccache is still mounted while
# cow.N/var/cache/pbuilder/ccache is already gone has, by construction,
# finished building and entered the unmount phase. A build still compiling
# always has both. We additionally require the condition to hold across two
# consecutive runs before acting, so a chroot caught mid-teardown is never
# disturbed.
#
# Install: /usr/local/sbin/pbuilder-umount-watchdog.sh, run from cron every
# 10 minutes as root (see the cron.d snippet at the bottom of this file).

set -u

BUILD_DIR=/var/cache/pbuilder/build
STAMP_DIR=/var/lib/pbuilder-umount-watchdog

log() { echo "pbuilder-umount-watchdog: $*"; logger -t pbuilder-umount-watchdog -- "$*" 2>/dev/null || true; }

mkdir -p "$STAMP_DIR"

is_mounted() {
    # findmnt is in util-linux; fall back to /proc/mounts if it is missing.
    if command -v findmnt >/dev/null 2>&1; then
        findmnt -rn --target "$1" -o TARGET 2>/dev/null | grep -qxF "$1"
    else
        awk -v t="$1" '$2 == t { found = 1 } END { exit !found }' /proc/mounts
    fi
}

# Kill every process holding something under the host path $1. Unlike the
# in-chroot hook, /proc paths here are read from the host, so they are absolute
# host paths (/var/cache/pbuilder/build/cow.N/opt/sccache/...) and matching on
# the full prefix keeps us confined to the one wedged chroot -- a concurrent
# build's sccache lives under a different cow.N and is never touched.
kill_holders() {
    local root=$1 signal=$2 killed=0 pid target

    for pid_dir in /proc/[0-9]*; do
        pid=${pid_dir#/proc/}
        [ "$pid" = "$$" ] && continue

        local hit=""
        for link in exe cwd root; do
            target=$(readlink "$pid_dir/$link" 2>/dev/null) || continue
            case "$target" in "$root"|"$root"/*) hit=1; break ;; esac
        done
        if [ -z "$hit" ] && [ -d "$pid_dir/fd" ]; then
            for fd in "$pid_dir"/fd/*; do
                target=$(readlink "$fd" 2>/dev/null) || continue
                case "$target" in "$root"|"$root"/*) hit=1; break ;; esac
            done
        fi
        if [ -z "$hit" ] && grep -qF " $root/" "$pid_dir/maps" 2>/dev/null; then
            hit=1
        fi

        if [ -n "$hit" ]; then
            log "SIG$signal to PID $pid ($(cat "$pid_dir/comm" 2>/dev/null)) holding $root"
            kill "-$signal" "$pid" 2>/dev/null || true
            killed=1
        fi
    done
    return $((1 - killed))
}

shopt -s nullglob
seen=()

for cow in "$BUILD_DIR"/cow.*; do
    [ -d "$cow" ] || continue
    name=${cow##*/}
    sccache_mnt="$cow/opt/sccache"
    ccache_mnt="$cow/var/cache/pbuilder/ccache"
    stamp="$STAMP_DIR/$name"

    # Not mounted, or the build is still running (ccache still bound): healthy.
    if ! is_mounted "$sccache_mnt" || is_mounted "$ccache_mnt"; then
        rm -f "$stamp"
        continue
    fi

    seen+=("$name")

    # First sighting: record it and wait for the next run to confirm. pbuilder
    # unmounts these back to back, so a healthy teardown never survives to the
    # second observation.
    if [ ! -f "$stamp" ]; then
        date +%s > "$stamp"
        log "$name: in the unmount phase with $sccache_mnt still mounted, will recheck next run"
        continue
    fi

    stuck_since=$(cat "$stamp" 2>/dev/null || echo 0)
    log "$name: still wedged since $(date -d "@$stuck_since" 2>/dev/null || echo "$stuck_since"), unblocking"

    kill_holders "$sccache_mnt" TERM && sleep 5
    kill_holders "$sccache_mnt" KILL && sleep 2

    if umount "$sccache_mnt" 2>/dev/null; then
        log "$name: unmounted $sccache_mnt"
    else
        # Lazy unmount detaches the mount immediately and lets pbuilder's retry
        # loop move on; the kernel frees the filesystem once the last reference
        # is dropped.
        umount -l "$sccache_mnt" 2>/dev/null \
            && log "$name: lazily detached $sccache_mnt" \
            || log "$name: WARNING could not unmount $sccache_mnt"
    fi

    rm -f "$stamp"
done

# Drop stamps for chroots that have gone away.
for stamp in "$STAMP_DIR"/*; do
    name=${stamp##*/}
    found=""
    for s in "${seen[@]:-}"; do [ "$s" = "$name" ] && found=1 && break; done
    [ -n "$found" ] || rm -f "$stamp"
done

exit 0

# Cron snippet -- install as /etc/cron.d/pbuilder-umount-watchdog:
#
#   SHELL=/bin/bash
#   PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
#   */10 * * * * root /usr/local/sbin/pbuilder-umount-watchdog.sh >/dev/null

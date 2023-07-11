#!/bin/bash
set -e
WHOAMI=$(whoami)

if test $WHOAMI != "jenkins"; then
	echo "should be run under jenkins"
fi

if test $# -ne 1 -a $# -ne 2; then
	echo "Wrong number of args."
	echo "Syntax: $0 <repository> <skip sync>"
	exit 1
fi

if ! grep -q XXX= ~/.ssh/known_hosts; then
	echo "Key unknown. added"
	echo "XXX" >> ~/.ssh/known_hosts
fi

check_package_versions() {
    # the distribution is the first argument to the function
    local base_dist=$1
    local path_repo=$2
    # check that the distribution name was provided
    if [ -z "$base_dist" ]; then
        echo "Error: No distribution provided"
        return 1
    fi

    # specify architectures here
    # don't care about i386
    local archs=("amd64" "s390x" "arm64")

    # specify versions here
    local versions=("15" "16" "")
    if test "$base_dist" != "unstable"; then
	base_dist="-$base_dist"
    else
	base_dist=""
    fi
    for ver in "${versions[@]}"; do
        local dist="llvm-toolchain${base_dist}${ver:+-}$ver"
        echo "Checking distribution $dist"

        # store versions in an associative array
        declare -A pkg_versions

        for arch in "${archs[@]}"; do
            echo "Architecture $arch"
            # list packages and versions
	    echo reprepro -b $path_repo/$1 list "${dist}" 
            local packages=$(reprepro -b $path_repo/$1 list "${dist}" | grep "$arch" | awk '{print $2,$3}')

            while read -r line; do
                pkg=$(echo "$line" | awk '{print $1}')
                ver=$(echo "$line" | awk '{print $2}')
		if [[ -n "$pkg" && -n "${pkg_versions[$pkg]}" && "${pkg_versions[$pkg]}" != "$ver" ]]; then
                    echo "error: $pkg has different versions for $arch: ${pkg_versions[$pkg]} vs $ver"
		    exit 1
                fi
		if [[ -n "$pkg" ]]; then
	                pkg_versions[$pkg]=$ver
		fi
            done <<< "$packages"
        done
    done
}


REPOSITORY=$1
SKIP_SYNC=$2
TARGET=apt@apt-origin.llvm.org
BASE_TARGETDIR=/data/apt/www
BASE_LOCALDIR=/srv/repository
if test ! -d $BASE_LOCALDIR/$REPOSITORY; then
	echo "Cannot find directory $REPOSITORY"
	exit 1
fi

LLVM_DEFAULT_DIR=$BASE_LOCALDIR/$REPOSITORY/pool/main/l/llvm-defaults/
if test ! -d $LLVM_DEFAULT_DIR/; then
        echo "Cannot find directory $LLVM_DEFAULT_DIR"
        exit 1
fi

check_package_versions $REPOSITORY $BASE_LOCALDIR
echo "=== version check completed before sync ==="

if test -z "$SKIP_SYNC"; then
find $BASE_LOCALDIR -type d | xargs chmod 755 || true
find $BASE_LOCALDIR -type f ! -name sync-to-llvm.sh | xargs -I {}  -d '\n' chmod 644 "{}" || true
ssh $TARGET mkdir -p $BASE_TARGETDIR/$REPOSITORY
echo "Delete potential old directory"
time ssh $TARGET rm -rf $BASE_TARGETDIR/$REPOSITORY.back
echo "Copy the current repo to a new directory to be updated"
time ssh $TARGET cp -Rp $BASE_TARGETDIR/$REPOSITORY $BASE_TARGETDIR/$REPOSITORY.back
echo "Sync the data"
time /usr/bin/rsync -a --info=progress2 --times --delete -v --stats -r $BASE_LOCALDIR/$REPOSITORY/* $TARGET:$BASE_TARGETDIR/$REPOSITORY.back/
echo "Kill the current repo (by renaming it)"
time ssh $TARGET mv $BASE_TARGETDIR/$REPOSITORY $BASE_TARGETDIR/$REPOSITORY.1
echo "Move the new repo to the actual dir"
time ssh $TARGET mv $BASE_TARGETDIR/$REPOSITORY.back $BASE_TARGETDIR/$REPOSITORY
echo "Delete the old repo"
time ssh $TARGET rm -rf $BASE_TARGETDIR/$REPOSITORY.1
fi

key="xxxx"
if test "$REPOSITORY" == "unstable"; then
    REPOSITORY_CODE=""
else
    REPOSITORY_CODE="-$REPOSITORY"
fi

purge_url() {
    API="https://api.fastly.com/purge"
    echo "================= Purge $1"
    curl -XPOST -H "Fastly-Key:$key" "$API/$1"
    echo ""
    # Can fail with a 404 as we just purged it
    curl -sLIXGET "https://$1" -H 'Fastly-Debug:1'
    echo "we should get HIT=1 now:"
    curl -sLIXGET "https://$1" -H 'Fastly-Debug:1'
    echo ""

}
cd /srv/repository/$REPOSITORY/dists/
url=$(ls -1 llvm-toolchain*/main/{source,binary*}/* */*Release*)
cd -
for f in $url; do
	FULL_URL="apt.llvm.org/$REPOSITORY/dists/$f"
	purge_url $FULL_URL
done

FULL_URL="apt.llvm.org/$REPOSITORY/"
purge_url $FULL_URL

#!/bin/bash
set -e

if test $# -ne 3; then
    echo "error"
    echo "syntax $0 DISTRO HOST ARCH"
    exit 1
fi

reprepro --version
dpkg -l reprepro

DISTRO=$1
HOST=$2
ARCH=$3

# reprepro needs to create db/lockfile. If anything left the repository owned by
# root (a manual run, a job that forgot the chown), every reprepro call below
# dies with "Error 13 creating lock file". Take ownership back here so the
# guarantee lives with the script instead of each job's config.
REPO_DIR=/srv/repository/$DISTRO
if test -d "$REPO_DIR" && ! test -w "$REPO_DIR/db"; then
    echo "$REPO_DIR/db not writable by $(whoami), taking ownership"
    ls -ld "$REPO_DIR" "$REPO_DIR/db" || true
    sudo /usr/bin/chown -R "$(id -un):$(id -gn)" "$REPO_DIR/"
    if ! test -w "$REPO_DIR/db"; then
        echo "ERROR: $REPO_DIR/db is still not writable after chown"
        exit 1
    fi
fi


declare -a old_versions=("9" "10" "11" "12" "13" "14" "15")

for version in "${old_versions[@]}"
do
    excludes+=(--exclude "pool/main/l/llvm-toolchain-$version/" --exclude "dists/llvm-toolchain-$DISTRO-$version/")
done
echo "Ignore ${excludes[@]}"
TEMP=-i
rsync $TEMP -avzh --delete "${excludes[@]}" jenkins@$HOST:/srv/repository/$DISTRO/ /tmp/tmp-$DISTRO/
if ! test -d /tmp/tmp-$DISTRO/pool/main/; then
        echo "Distro $DISTRO not existing yet"
        exit 0
fi


versions=("15" "16" "17" "18" "")
for ver in "${versions[@]}"; do

    declare -A src_pkg_versions
    declare -A dst_pkg_versions
    if test "$DISTRO" != "unstable"; then
        base_dist="-$DISTRO"
    else
        base_dist=""
    fi
    dist="llvm-toolchain${base_dist}${ver:+-}$ver"
    echo $dist

    remote_packages=$(reprepro -b /tmp/tmp-$DISTRO/ list "$dist" | grep "$ARCH" | awk '{print $2,$3}')
    while read -r line; do
        pkg=$(echo "$line" | awk '{print $1}')
        ver=$(echo "$line" | awk '{print $2}')
        if [[ -n "$pkg" ]]; then
            src_pkg_versions["$pkg"]=$ver
        fi
    done <<< "$remote_packages"
    echo "Number packages coming from $ARCH: ${#src_pkg_versions[@]}"
    echo "To see the list: reprepro -b /tmp/tmp-$DISTRO/ list '$dist'"

    repo_packages=$(reprepro -b /srv/repository/$DISTRO/ list "$dist" | grep "amd64" | awk '{print $2,$3}')
    while read -r line; do
        pkg=$(echo "$line" | awk '{print $1}')
        ver=$(echo "$line" | awk '{print $2}')
        if [[ -n "$pkg" ]]; then
            dst_pkg_versions["$pkg"]=$ver
        fi
    done <<< "$repo_packages"
    echo "Number of local amd64 packages: ${#src_pkg_versions[@]}"
    echo "To see the list: reprepro -b /srv/repository/$DISTRO/ list '$dist'"

    for pkg in "${!src_pkg_versions[@]}"; do
        if [[ -n "${dst_pkg_versions[$pkg]}" && "${src_pkg_versions[$pkg]}" != "${dst_pkg_versions[$pkg]}" ]]; then
            echo "error: $pkg has different versions for $ARCH: ${src_pkg_versions[$pkg]} vs ${dst_pkg_versions[$pkg]}"
	    echo -n "build id: "
            echo -n ${src_pkg_versions[$pkg]} | awk -F"." '{printf "%s", $2}'
            echo -n " / "
            echo ${dst_pkg_versions[$pkg]} | awk -F"." '{print $2}'
	    #            exit 1
        fi
    done
done
echo "=== version check completed ==="

for f in /tmp/tmp-$DISTRO/dists/llvm-*/main/binary-$ARCH/; do
    echo "f= $f"
    echo "DISTRO = $DISTRO"
    VERSION=$(echo "$f" | sed -E -e "s|/tmp/tmp-$DISTRO/dists/llvm-toolchain(-$DISTRO)?-?([[:digit:]]+)/.*|\2|g")
    echo "VERSION $VERSION"
    re='^[0-9]+$'

    # Skip if version is in versions array
    if [[ " ${old_versions[*]} " == *" $VERSION "* ]]; then
        echo "Skipping old version $VERSION"
        continue
    fi

    if ! [[ $VERSION =~ $re ]] ; then
            # maybe debian unstable
            VERSION=$(echo $f|sed -e "s|/tmp/tmp-$DISTRO/dists/llvm-toolchain-\([[:digit:]]\+\)/.*|\1|g")
            if ! [[ $VERSION =~ $re ]] ; then
                echo "Probably the nightly version"
                break
            fi
    fi
    # Workaround: don't import libclc (provided by amd64)
    # checksum differences otherwise
    rm -f /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain*/libclc-*deb

    # Second workaround to remove _all packages
    rm -f /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain*/*_all.deb

    # Import of the stable and stabilisation version
    if test $DISTRO == "unstable"; then
        reprepro -Vb /srv/repository/$DISTRO/ includedeb llvm-toolchain-$VERSION /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain-$VERSION/*deb
    else
        echo reprepro -Vb /srv/repository/$DISTRO/ includedeb llvm-toolchain-$DISTRO-$VERSION /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain-$VERSION/*deb
        reprepro -Vb /srv/repository/$DISTRO/ includedeb llvm-toolchain-$DISTRO-$VERSION /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain-$VERSION/*deb
    fi
done

# Import of the nightly builds
if [[ -d /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain/ || -d /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain-snapshot/ ]]; then
    # Determine package name based on DISTRO
    PKG_NAME="llvm-toolchain"
    if [[ $DISTRO != "unstable" ]]; then
        PKG_NAME+="-$DISTRO"
    fi

    # Collect the incoming .deb set before touching the repository. The removal
    # loop below is destructive and has no rollback: if the includedeb that
    # follows it ends up with nothing to install, the distribution keeps only
    # its Architecture: all packages, and clang-N along with every other
    # arch-specific package disappears from the index until the next successful
    # sync. The guard above accepts both pool names, so look in both instead of
    # hardcoding one and letting an unexpanded glob reach reprepro.
    incoming=()
    for pool_dir in /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain-snapshot /tmp/tmp-$DISTRO/pool/main/l/llvm-toolchain; do
        test -d "$pool_dir" || continue
        while IFS= read -r deb; do
            incoming+=("$deb")
        done < <(find "$pool_dir" -maxdepth 1 -type f -name '*.deb' | sort)
    done

    if [ ${#incoming[@]} -eq 0 ]; then
        echo "ERROR: no .deb to import into $PKG_NAME, keeping the current $ARCH packages"
        exit 1
    fi

    # _all.deb alone is not enough: the removal below only drops the
    # arch-specific packages, so importing nothing but Architecture: all would
    # empty the $ARCH index just the same.
    arch_debs=0
    for deb in "${incoming[@]}"; do
        case "$deb" in
            *_"$ARCH".deb) arch_debs=$((arch_debs + 1)) ;;
        esac
    done
    if [ "$arch_debs" -eq 0 ]; then
        echo "ERROR: ${#incoming[@]} .deb found for $PKG_NAME but none built for $ARCH;"
        echo "       removing the current ones would leave the index without any"
        exit 1
    fi
    echo "Importing ${#incoming[@]} package(s) into $PKG_NAME ($arch_debs for $ARCH)"

    # Get the list of packages (but don't get the _all packages)
    LIST=$(reprepro -A $ARCH -Vb /srv/repository/$DISTRO/  listfilter $PKG_NAME  'Architecture (!= all)' | awk '{print $2}')
    echo "Delete $LIST (existing package) on $ARCH before includedeb"

    # Remove the listed packages
    for pkg in $LIST; do
        echo "reprepro -A $ARCH -Vb /srv/repository/$DISTRO/ remove $PKG_NAME $pkg"
        reprepro -A $ARCH -Vb /srv/repository/$DISTRO/ remove $PKG_NAME $pkg
    done

    # Include the deb package(s)
    reprepro -Vb /srv/repository/$DISTRO/ includedeb $PKG_NAME "${incoming[@]}"

    # Last chance to notice an empty $ARCH before the repository is synced out.
    if ! reprepro -A $ARCH -b /srv/repository/$DISTRO/ listfilter $PKG_NAME 'Architecture (!= all)' | grep -q .; then
        echo "ERROR: $PKG_NAME has no $ARCH package left after the import"
        exit 1
    fi
fi

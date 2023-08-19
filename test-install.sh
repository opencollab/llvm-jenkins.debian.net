#!/bin/bash
set -e -v

# If no argument provided, test all
# If 2 are provided, distro + version
# If USE_SCRIPT=1 is set, use llvm.sh to install the packages

DISTRO="buster bullseye bookworm unstable bionic focal jammy kinetic lunar"
VERSION="10 11 12 13 14 15 16 17"
VERSION_NEXT="18"

if test $# -eq 1; then
    JOB_NAME=$1
    echo "JOB_NAME passed = $JOB_NAME"

    # Can be:
    # * llvm-toolchain-11-integration-test
    # * llvm-toolchain-12-integration-test
    # * llvm-toolchain-integration-test
    # * llvm-toolchain-bullseye-11-integration-test
    # * llvm-toolchain-bullseye-12-integration-test
    # * llvm-toolchain-bullseye-integration-test
    # * ...

    if echo $JOB_NAME|grep -E "llvm-toolchain-.*-integration-test"; then
        # Main for all distro but unstable
        DISTRO=$(echo $JOB_NAME|sed -e "s|llvm-toolchain-\(.*\)-integration-test|\1|g")
        VERSION=$VERSION_NEXT
    fi


    if echo $JOB_NAME|grep -E "llvm-toolchain-.*-[0-9]*-integration-test"; then
        # ex: llvm-toolchain-bullseye-11-integration-test
        DISTRO=$(echo $JOB_NAME|sed -e "s|llvm-toolchain-\(.*\)-\(.*\)-integration-test|\1|g")
        VERSION=$(echo $JOB_NAME|sed -e "s|llvm-toolchain-\(.*\)-\(.*\)-integration-test|\2|g")
    fi


    if test "$JOB_NAME" = "llvm-toolchain-integration-test"; then
        # Special case for Debian unstable with main
        DISTRO=unstable
        VERSION=$VERSION_NEXT
    fi

    if echo $JOB_NAME|grep -E "llvm-toolchain-[0-9]*-integration-test"; then
        # Debian unstable for non main
        DISTRO=unstable
        VERSION=$(echo $JOB_NAME|sed -e "s|llvm-toolchain-\(.*\)-integration-test|\1|g")
    fi

fi
echo "DISTRO = $DISTRO"
echo "VERSION = $VERSION"

# Create the chroots
for d in $DISTRO; do

    MIRROR=""
    if test "$d" == "buster" -o "$d" == "bullseye" -o "$d" == "unstable"; then
        # deb.debian.org is failing too often
        MIRROR=http://cloudfront.debian.net/debian
    fi
    if test ! -d $d.chroot; then
        echo "Create $d chroot"
        sudo debootstrap $d $d.chroot $MIRROR
    fi
    if test ! -e $0.chroot/proc/uptime; then
        sudo mount -t proc /proc $d.chroot/proc || true
    fi
    if test ! -e $0.chroot/dev/shm; then
        sudo mount --bind /dev/shm "$d.chroot/dev/shm" || true
    fi
    if test ! -e $0.chroot/dev/pts; then
        sudo mount --bind /dev/pts "$d.chroot/dev/pts" || true
    fi
done


TEMPLATE="deb http://apt.llvm.org/@DISTRO_PATH@/ llvm-toolchain@DISTRO@ main"
TEMPLATE_VERSION="deb http://apt.llvm.org/@DISTRO_PATH@/ llvm-toolchain@DISTRO@-@VERSION@ main"

for d in $DISTRO; do
    echo "" > $d.list
    # Only include the snapshot repo when it is requested
    # When we want X, only install X
    if test "$d" != "unstable"; then
        echo $TEMPLATE|sed -e "s|@DISTRO@|-$d|g" -e "s|@DISTRO_PATH@|$d|g" >> $d.list
    else
        echo $TEMPLATE|sed -e "s|@DISTRO@||g" -e "s|@DISTRO_PATH@|$d|g" >> $d.list
    fi

    if test "$d" == "bionic" -o "$d" == "focal" -o "$d" == "groovy" -o "$d" == "hirsute" -o "$d" == "impish" -o "$d" == "jammy" -o "$d" == "kinetic" -o "$d" == "lunar"; then
        # focal, groovy, etc need universe
        if test "$(arch)" == "s390x"; then
            echo "deb http://ports.ubuntu.com/ubuntu-ports $d universe" >> $d.list
        else
            echo "deb http://www-ftp.lip6.fr/pub/linux/distributions/Ubuntu/ $d universe"  >> $d.list
        fi
    fi

    for v in $VERSION; do
        if test $v == "9" -o $v == "10"; then
            if test "$d" == bullseye; then
                continue
            fi
        fi
        if test $v == "9" -a $d == "groovy"; then
            continue
        fi
        if test $v == "9" -a $d == "hirsute"; then
            continue
        fi

        if test $v == "9" -o $v == "10" -o $v == "11"; then
            if test "$d" == "impish"; then
                continue
            fi
            if test "$(arch)" == "aarch64"; then
                # no support before 12
                continue
            fi
        fi

        if test $v != "$VERSION_NEXT"; then
            # If the user entered the current trunk
            # Skip this
            if test "$d" != "unstable"; then
                echo $TEMPLATE_VERSION|sed -e "s|@DISTRO@|-$d|g" -e "s|@DISTRO_PATH@|$d|g" -e "s|@VERSION@|$v|g" >> $d.list
            else
                echo $TEMPLATE_VERSION|sed -e "s|@DISTRO@||g" -e "s|@DISTRO_PATH@|$d|g" -e "s|@VERSION@|$v|g" >> $d.list
            fi
        fi
    done
    sudo cp $d.list $d.chroot/etc/apt/sources.list.d/clang.list

    echo "
     Package: *
     Pin: origin apt.llvm.org
     Pin-Priority: 1000" > $d.pref
    sudo cp $d.pref /etc/apt/preferences.d/local-pin-900
done

if test $# -ne 1; then
    # No version specified, install also snapshot
    VERSION="$VERSION $VERSION_NEXT"
fi

for d in $DISTRO; do
    echo "========= Install on $d"
    PKG=""
    CMD=""
    for v in $VERSION; do
        if test $v == "9" -o $v == "10"; then
            if test "$d" == bullseye; then
                # 9 and 10 aren't supported for this distro
                continue
            fi
        fi
        if test $v == "9" -a $d == "groovy"; then
            # 9 isn't supported for this distro
            continue
        fi
        if test $v == "9" -a $d == "hirsute"; then
            # 9 isn't supported for this distro
            continue
        fi
        if test $v == "9" -o $v == "10" -o $v == "11"; then
            if test "$d" == "impish"; then
                # 9, 10 and 11 aren't supported for this distro
                continue
            fi
            if test "$(arch)" == "aarch64"; then
                # no support before 12
                continue
            fi

        fi

        if test -z "$USE_SCRIPT"; then

            PKG="$PKG clang-$v clangd-$v clang-tidy-$v clang-format-$v clang-tools-$v llvm-$v-dev lld-$v lldb-$v llvm-$v-tools libomp-$v-dev libc++-$v-dev libc++abi-$v-dev libclang-common-$v-dev libclang-$v-dev libclang-cpp$v-dev"
            if test "$d" != "unstable" -a "$d" != "jammy" -a "$d" != "kinetic" -a "$d" != "lunar" -a "$d" != "bookworm"; then
                PKG="$PKG python"
            fi
            if test $v -gt 13; then
                # libclang-rt isn't package for -13
                PKG="$PKG libclang-rt-$v-dev"
            fi
            if test $v -gt 11; then
                # libunwind isn't packaged for -11
                PKG="$PKG libunwind-$v-dev"
            fi
	        # temporary workaround to make scan-build-py work
	        PKG="$PKG clang"
            CMD="clang-$v --version; $CMD"
        fi
    done

    CMAKE_EXTRA="-DENABLE_STATIC_LIBCXX=ON -DLIBUNWIND_ENABLED=ON"
    if test $v -lt 12; then
        # < 12 is buggy
        # See https://github.com/opencollab/llvm-toolchain-integration-test-suite/commit/5092077049adb498cecce02cd86feffb817e5cfd
        CMAKE_EXTRA="-DENABLE_STATIC_LIBCXX=OFF -DENABLE_LIBUNWIND=OFF"
    fi

    echo "
         set -e
         apt install -y wget gnupg git cmake g++ lsb-release software-properties-common
         wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc
    " > $d-script.sh

    if test "$d" == bionic; then
        echo "
             apt install -y software-properties-common
             add-apt-repository -y ppa:ubuntu-toolchain-r/test
             apt install -y libstdc++-8-dev
        " >> $d-script.sh
    fi

    if test "$d" == "jammy" -o "$d" == "buster"; then
        PKG="$PKG zlib1g-dev"
    fi

    echo "USE_SCRIPT=$USE_SCRIPT"
    if test -z "$USE_SCRIPT"; then
        # install packages by hands
        echo "
             # Install necessary package to setup + run the testsuite
             apt update
             echo \"Install $PKG\"
             apt install -y $PKG --no-install-recommends
             $CMD
             bash /root/run-testsuite.sh
             apt remove --purge -y $PKG
     " >> $d-script.sh
    else
        # Test llvm.sh
        echo "
             # Install necessary package to setup + run the testsuite with llvm.sh
             cd /root
             wget https://apt.llvm.org/llvm.sh
             chmod +x /root/llvm.sh
             echo 'llvm.sh $v (minimal packages)'
             /root/llvm.sh $v
             echo 'llvm.sh $v all (all packages)'
             /root/llvm.sh $v all
             bash /root/run-testsuite.sh
     " >> $d-script.sh
    fi
    echo "
     set -e -v
     rm -rf check
     git clone https://github.com/opencollab/llvm-toolchain-integration-test-suite.git check
     cd check
     mkdir build && cd build &&
     cmake -DLIT=/usr/lib/llvm-$v/build/utils/lit/lit.py \
          -DCLANG_BINARY=/usr/bin/clang-$v \
          -DCLANGD_BINARY=/usr/bin/clangd-$v \
          -DCLANGXX_BINARY=/usr/bin/clang++-$v \
          -DCLANG_TIDY_BINARY=/usr/bin/clang-tidy-$v \
          -DCLANG_FORMAT_BINARY=/usr/bin/clang-format-$v \
          -DCLANG_FORMAT_DIFF_BINARY=/usr/bin/clang-format-diff-$v \
          -DLLD_BINARY=/usr/bin/lld-$v \
          -DLLDB_BINARY=/usr/bin/lldb-$v \
          -DLLVMCONFIG_BINARY=/usr/bin/llvm-config-$v \
          -DOPT_BINARY=/usr/bin/opt-$v \
          -DSCANBUILD=/usr/bin/scan-build-$v \
          -DSCANBUILDPY=/usr/bin/scan-build-py-$v \
          -DCLANG_TIDY_BINARY=/usr/bin/clang-tidy-$v \
          -DSCANVIEW=/usr/bin/scan-view-$v \
          -DLLVMNM=/usr/bin/llvm-nm-$v \
          -DLLC=/usr/bin/llc-$v \
          -DLLI=/usr/bin/lli-$v \
          -DOPT=/usr/bin/opt-$v \
          -DLLVMPROFDATA=/usr/bin/llvm-profdata-$v \
          -DENABLE_COMPILER_RT=ON \
          -DENABLE_LIBCXX=ON \
          $CMAKE_EXTRA \
          ../ && \
          make check
     " > $d-run-testsuite.sh
    cat $d-run-testsuite.sh
    cat $d-script.sh
    sudo cp $d-script.sh $d.chroot/root/install.sh
    sudo cp $d-run-testsuite.sh $d.chroot/root/run-testsuite.sh
    sudo chroot $d.chroot/ /bin/bash -c "bash /root/install.sh"
done

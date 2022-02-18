<?php
function getLastUpdate($distro) {
   $base="/data/apt/www";
   if ($distro!="unstable") {
     $fullpath=$base."/${distro}/dists/llvm-toolchain-{$distro}/Release";
   } else {
     $fullpath=$base."/${distro}/dists/llvm-toolchain/Release";
   }
   $handle = fopen($fullpath, "r");
   $contents = fread($handle, filesize($fullpath));
   preg_match("/Date: (.*)/",$contents,$matches);
   return $matches[1];
}
function getLastRevision($distro) {
   $base="/data/apt/www";
   if ($distro!="unstable") {
     $fullpath=$base."/${distro}/dists/llvm-toolchain-{$distro}/main/binary-amd64/Packages";
   } else {
     $fullpath=$base."/${distro}/dists/llvm-toolchain/main/binary-amd64/Packages";
   }
//echo $fullpath;
   $handle = fopen($fullpath, "r");
   $contents = fread($handle, filesize($fullpath));
   preg_match("/Version: .*~++(.*)-/",$contents,$matches);
   return str_replace("++", "", $matches[1]);
}

$stableBranch="13";
$qualificationBranch="14";
$devBranch="15";
$isQualification=true;
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
                      "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <title>LLVM Debian/Ubuntu packages</title>
  <link rel="stylesheet" type="text/css" href="//llvm.org/llvm.css">
</head>
<body>

<div class="rel_title">
  LLVM Debian/Ubuntu nightly packages
</div>

<div class="rel_container">

<div class="rel_section">Download</div>

<div class="rel_boxtext">

  <p>The goal is to provide Debian and Ubuntu nightly packages ready to be installed with minimal impact on the distribution.<br />Packages are available for amd64, i386 (except for recent Ubuntu), s390x and arm64 (aka aarch64). This for both the stable, <?php if ($isQualification) {?>qualification<?php } else {?>old-stable<?php } ?> and development branches (currently <?=$stableBranch?>, <?=$qualificationBranch?> and <?=$devBranch?>).</p>
<p>Packages are built using stage2 and extremely similar to the one shipping in Debian & Ubuntu.</p>
<p>The packages provide <a href="https://llvm.org/">LLVM</a> + <a href="https://clang.llvm.org/">Clang</a> + <a href="https://compiler-rt.llvm.org/">compiler-rt</a> + <a href="https://polly.llvm.org/">polly</a> + <a href="https://lldb.llvm.org/">LLDB</a> + <a href="https://lld.llvm.org/">LLD</a> + <a href="https://llvm.org/docs/LibFuzzer.html">libFuzzer</a> + <a href="https://libcxx.llvm.org/">libc++</a> + <a href="https://libcxxabi.llvm.org/">libc++abi</a> + <a href="https://openmp.llvm.org/">openmp</a> + <a href="https://libclc.llvm.org/">libclc</a> + <a href="https://github.com/llvm/llvm-project/tree/main/libunwind">libunwind</a> + <a href="https://mlir.llvm.org/">MLIR</a></p>
</div>
<div class="rel_section">News</div>

<div class="rel_boxtext">
Feb 18th 2022 - Ubuntu Jammy (22.04) enabled<br />
Feb 04th 2022 - Snapshot becomes 15, branch 14 created<br />
Jan 16th 2022 - llvm.sh can now install all packages at once with the <a href="#llvmsh">'all' option</a><br />
Jan 15th 2022 - Sources and dsc files are signed on <a href="#sigstore">sigstore</a><br />
Dec 30th 2021 - <a href="https://mlir.llvm.org/">MLIR</a> packages added from 13<br />
Dec 23th 2021 - Ubuntu Groovy (20.10) disabled (EOL)<br />
Dec 22nd 2021 - arm64 supported<br />
Nov 02nd 2021 - Infra <a href="https://blog.llvm.org/posts/2021-11-02-apt.llvm.org-moving-from-physical-server-to-the-cloud/">moved to the cloud</a><br />
Oct 05th 2021 - Ubuntu Impish (21.10) enabled<br />
Aug 01st 2021 - Snapshot becomes 14, branch 13 created<br />
Aug 01st 2021 - libunwind packages are generated (libunwind-XX & libunwind-XX-dev)<br />
Jul 25th 2021 - Packages are tested against the <a href="https://github.com/opencollab/llvm-toolchain-integration-test-suite/">LLVM integration test suite</a><br />
<!--May 10th 2021 - Debian strech disabled (quite old). If you are still using, <a href="mailto:sylvestre@debian.org">mail me</a><br />-->
May 01st 2021 - libclc packages generated from 12. Thanks to Timo Aaltonen<br />
Apr 25th 2021 - S390X support added<br />
Mar 28th 2021 - Ubuntu Xenial (16.04) disabled (EOL)<br />
Feb 01st 2021 - Snapshot becomes 13, branch 12 created<br />
Feb 01st 2021 - Debian Bullseye (11) added<br />
</div>

<div class="rel_section" id="llvmsh">Automatic installation script</div>
<div class="rel_boxtext">
For convenience there is an automatic installation script available that installs LLVM for you.<br />

To install the latest stable version:
<pre>
bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
</pre>
<br />

To install a specific version of LLVM:
<pre>
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh &lt;version number&gt;
</pre>

To install all apt.llvm.org packages at once:
<pre>
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh &lt;version number&gt; all
# or
sudo ./llvm.sh all
</pre>

Additionally, there are options to specify the mirror and distro version to use, for example:
<pre>
sudo ./llvm.sh -m https://mirrors.tuna.tsinghua.edu.cn/llvm-apt -n bionic
</pre>

You can use <a href="https://mirrorz.org/list/llvm-apt">MirrorZ</a> to find some available mirror sites.

For more details, please check the synopsis by running the script with -h option.
</div>

<div class="rel_section">Debian</div>

<div class="rel_boxtext">

Stretch (Debian 9 - old-old-stable) - <small>Last update : <?=getLastUpdate("stretch");?> / Revision: <?=getLastRevision("stretch")?></small>
<pre>
deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch main
deb-src http://apt.llvm.org/stretch/ llvm-toolchain-stretch main
# <?=$stableBranch?> 
deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch-<?=$stableBranch?> main
deb-src http://apt.llvm.org/stretch/ llvm-toolchain-stretch-<?=$stableBranch?> main
# <?=$qualificationBranch?> 
deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch-<?=$qualificationBranch?> main
deb-src http://apt.llvm.org/stretch/ llvm-toolchain-stretch-<?=$qualificationBranch?> main
</pre>

Buster (Debian 10 - old-stable) - <small>Last update : <?=getLastUpdate("buster");?> / Revision: <?=getLastRevision("buster")?></small>
<pre>
deb http://apt.llvm.org/buster/ llvm-toolchain-buster main
deb-src http://apt.llvm.org/buster/ llvm-toolchain-buster main
# <?=$stableBranch?> 
deb http://apt.llvm.org/buster/ llvm-toolchain-buster-<?=$stableBranch?> main
deb-src http://apt.llvm.org/buster/ llvm-toolchain-buster-<?=$stableBranch?> main
# <?=$qualificationBranch?> 
deb http://apt.llvm.org/buster/ llvm-toolchain-buster-<?=$qualificationBranch?> main
deb-src http://apt.llvm.org/buster/ llvm-toolchain-buster-<?=$qualificationBranch?> main
</pre>

Bullseye (Debian 11 -  stable) - <small>Last update : <?=getLastUpdate("bullseye");?> / Revision: <?=getLastRevision("bullseye")?></small>
<pre>
deb http://apt.llvm.org/bullseye/ llvm-toolchain-bullseye main
deb-src http://apt.llvm.org/bullseye/ llvm-toolchain-bullseye main
# <?=$stableBranch?> 
deb http://apt.llvm.org/bullseye/ llvm-toolchain-bullseye-<?=$stableBranch?> main
deb-src http://apt.llvm.org/bullseye/ llvm-toolchain-bullseye-<?=$stableBranch?> main
# <?=$qualificationBranch?> 
deb http://apt.llvm.org/bullseye/ llvm-toolchain-bullseye-<?=$qualificationBranch?> main
deb-src http://apt.llvm.org/bullseye/ llvm-toolchain-bullseye-<?=$qualificationBranch?> main
</pre>


sid (unstable) - <small>Last update : <?=getLastUpdate("unstable");?> / Revision: <?=getLastRevision("unstable")?></small>
<!--# Need Debian experimental too-->
<pre>
deb http://apt.llvm.org/unstable/ llvm-toolchain main
deb-src http://apt.llvm.org/unstable/ llvm-toolchain main
# <?=$stableBranch?> 
deb http://apt.llvm.org/unstable/ llvm-toolchain-<?=$stableBranch?> main
deb-src http://apt.llvm.org/unstable/ llvm-toolchain-<?=$stableBranch?> main
# <?=$qualificationBranch?> 
deb http://apt.llvm.org/unstable/ llvm-toolchain-<?=$qualificationBranch?> main
deb-src http://apt.llvm.org/unstable/ llvm-toolchain-<?=$qualificationBranch?> main

</pre>

</div>
<div class="rel_section">Ubuntu</div>
<div class="rel_boxtext">
Precise, Quantal, Raring, Saucy, Utopic, Artful, Cosmic, Eoan and Trusty are no longer supported by Ubuntu. Repo remains available but not updated.<br />
<br />
As i386 isn't supported by Ubuntu anymore, apt.llvm.org isn't either.<br />
<br />
Bionic LTS (18.04) - <small>Last update : <?=getLastUpdate("bionic");?> / Revision: <?=getLastRevision("bionic")?></small>
<pre>
deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic main
deb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic main
# Needs 'sudo add-apt-repository ppa:ubuntu-toolchain-r/test' for libstdc++ with C++20 support
# <?=$stableBranch?>

deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-<?=$stableBranch?> main
deb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic-<?=$stableBranch?> main
# <?=$qualificationBranch?>

deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-<?=$qualificationBranch?> main
deb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic-<?=$qualificationBranch?> main
</pre>

Focal (20.04) LTS - <small>Last update : <?=getLastUpdate("focal");?> / Revision: <?=getLastRevision("focal")?></small>
<pre>
deb http://apt.llvm.org/focal/ llvm-toolchain-focal main
deb-src http://apt.llvm.org/focal/ llvm-toolchain-focal main
# <?=$stableBranch?>

deb http://apt.llvm.org/focal/ llvm-toolchain-focal-<?=$stableBranch?> main
deb-src http://apt.llvm.org/focal/ llvm-toolchain-focal-<?=$stableBranch?> main
# <?=$qualificationBranch?>

deb http://apt.llvm.org/focal/ llvm-toolchain-focal-<?=$qualificationBranch?> main
deb-src http://apt.llvm.org/focal/ llvm-toolchain-focal-<?=$qualificationBranch?> main
</pre>

Hirsute (21.04) - <small>Last update : <?=getLastUpdate("hirsute");?> / Revision: <?=getLastRevision("hirsute")?></small>
<pre>
deb http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute main
deb-src http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute main
# <?=$stableBranch?>

deb http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute-<?=$stableBranch?> main
deb-src http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute-<?=$stableBranch?> main
# <?=$qualificationBranch?>

deb http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute-<?=$qualificationBranch?> main
deb-src http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute-<?=$qualificationBranch?> main
</pre>

Impish (21.10) - <small>Last update : <?=getLastUpdate("impish");?> / Revision: <?=getLastRevision("impish")?></small>
<pre>
deb http://apt.llvm.org/impish/ llvm-toolchain-impish main
deb-src http://apt.llvm.org/impish/ llvm-toolchain-impish main
# <?=$stableBranch?>

deb http://apt.llvm.org/impish/ llvm-toolchain-impish-<?=$stableBranch?> main
deb-src http://apt.llvm.org/impish/ llvm-toolchain-impish-<?=$stableBranch?> main
# <?=$qualificationBranch?>

deb http://apt.llvm.org/impish/ llvm-toolchain-impish-<?=$qualificationBranch?> main
deb-src http://apt.llvm.org/impish/ llvm-toolchain-impish-<?=$qualificationBranch?> main
</pre>

Jammy (22.04) - <small>Last update : <?=getLastUpdate("jammy");?> / Revision: <?=getLastRevision("jammy")?></small>
<pre>
deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy main
deb-src http://apt.llvm.org/jammy/ llvm-toolchain-jammy main
# <?=$stableBranch?>

deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-<?=$stableBranch?> main
deb-src http://apt.llvm.org/jammy/ llvm-toolchain-jammy-<?=$stableBranch?> main
# <?=$qualificationBranch?>

deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-<?=$qualificationBranch?> main
deb-src http://apt.llvm.org/jammy/ llvm-toolchain-jammy-<?=$qualificationBranch?> main
</pre>

</div>
<a href="#" id="default_pkg" style="visibility: hidden">default_pkg</a>
<div class="rel_section">Default packages</div>
<div class="rel_boxtext">
          To make sure always the most recent versions of the packages are installed, we are providing some default packages.<br />To install all of them (currently version <?=$devBranch?>):
<p class="www_code">
        apt-get install clang-format clang-tidy clang-tools clang clangd libc++-dev libc++1 libc++abi-dev libc++abi1 libclang-dev libclang1 liblldb-dev libllvm-ocaml-dev libomp-dev libomp5 lld lldb llvm-dev llvm-runtime llvm python3-clang
</p>
</div>

<a href="#" id="install_stable" style="visibility: hidden">install_stable</a>
<div class="rel_section">Install<br />(<?php if (!$isQualification) {?>old-<?php } ?>stable branch)</div>
<div class="rel_boxtext">
To retrieve the archive signature:
  <p class="www_code">
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -<br />
# Fingerprint:  6084 F3CF 814B 57C1 CF12  EFD5 15CF 4D18 AF4F 7421
</p><br />

To install just clang, lld and lldb (<?=$stableBranch?> release):
  <p class="www_code">
apt-get install clang-<?=$stableBranch?> lldb-<?=$stableBranch?> lld-<?=$stableBranch?>
</p>
<br />
To install all key packages:<br />
<p class="www_code">
<b># LLVM</b><br />
apt-get install libllvm-<?=$stableBranch?>-ocaml-dev libllvm<?=$stableBranch?> llvm-<?=$stableBranch?> llvm-<?=$stableBranch?>-dev llvm-<?=$stableBranch?>-doc llvm-<?=$stableBranch?>-examples llvm-<?=$stableBranch?>-runtime<br />
<b># Clang and co</b><br />
apt-get install clang-<?=$stableBranch?> clang-tools-<?=$stableBranch?> clang-<?=$stableBranch?>-doc libclang-common-<?=$stableBranch?>-dev libclang-<?=$stableBranch?>-dev libclang1-<?=$stableBranch?> clang-format-<?=$stableBranch?> python3-clang-<?=$stableBranch?> clangd-<?=$stableBranch?> clang-tidy-<?=$stableBranch?> <br />
<b># libfuzzer</b><br />
apt-get install libfuzzer-<?=$stableBranch?>-dev<br />
<b># lldb</b><br />
apt-get install lldb-<?=$stableBranch?><br />
<b># lld (linker)</b><br />
apt-get install lld-<?=$stableBranch?><br />
<b># libc++</b><br />
apt-get install libc++-<?=$stableBranch?>-dev libc++abi-<?=$stableBranch?>-dev<br />
<b># OpenMP</b><br />
apt-get install libomp-<?=$stableBranch?>-dev<br />
<b># libclc</b><br />
apt-get install libclc-<?=$stableBranch?>-dev<br />
<b># libunwind</b><br />
apt-get install libunwind-<?=$stableBranch?>-dev<br />
<b># mlir</b><br />
apt-get install libmlir-<?=$stableBranch?>-dev mlir-<?=$stableBranch?>-tools<br />
</p>
</div>

<a href="#" id="install_qualification" style="visibility: hidden">install_qualification</a>

<div class="rel_section">Install<br />(<?php if ($isQualification) {?>qualification<?php } else {?>stable<?php } ?> branch)</div>
<div class="rel_boxtext">
To retrieve the archive signature:
  <p class="www_code">
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -<br />
# Fingerprint:  6084 F3CF 814B 57C1 CF12  EFD5 15CF 4D18 AF4F 7421
</p><br />

To install just clang, lld and lldb (<?=$qualificationBranch?> release):
  <p class="www_code">
apt-get install clang-<?=$qualificationBranch?> lldb-<?=$qualificationBranch?> lld-<?=$qualificationBranch?>
</p>
<br />
To install all key packages:<br />
<p class="www_code">
<b># LLVM</b><br />
apt-get install libllvm-<?=$qualificationBranch?>-ocaml-dev libllvm<?=$qualificationBranch?> llvm-<?=$qualificationBranch?> llvm-<?=$qualificationBranch?>-dev llvm-<?=$qualificationBranch?>-doc llvm-<?=$qualificationBranch?>-examples llvm-<?=$qualificationBranch?>-runtime<br />
<b># Clang and co</b><br />
apt-get install clang-<?=$qualificationBranch?> clang-tools-<?=$qualificationBranch?> clang-<?=$qualificationBranch?>-doc libclang-common-<?=$qualificationBranch?>-dev libclang-<?=$qualificationBranch?>-dev libclang1-<?=$qualificationBranch?> clang-format-<?=$qualificationBranch?> python3-clang-<?=$qualificationBranch?> clangd-<?=$qualificationBranch?> clang-tidy-<?=$qualificationBranch?><br />
<b># libfuzzer</b><br />
apt-get install libfuzzer-<?=$qualificationBranch?>-dev<br />
<b># lldb</b><br />
apt-get install lldb-<?=$qualificationBranch?><br />
<b># lld (linker)</b><br />
apt-get install lld-<?=$qualificationBranch?><br />
<b># libc++</b><br />
apt-get install libc++-<?=$qualificationBranch?>-dev libc++abi-<?=$qualificationBranch?>-dev<br />
<b># OpenMP</b><br />
apt-get install libomp-<?=$qualificationBranch?>-dev<br />
<b># libclc</b><br />
apt-get install libclc-<?=$qualificationBranch?>-dev<br />
<b># libunwind</b><br />
apt-get install libunwind-<?=$qualificationBranch?>-dev<br />
<b># mlir</b><br />
apt-get install libmlir-<?=$qualificationBranch?>-dev mlir-<?=$qualificationBranch?>-tools<br />
</p>

</div>


<a href="#" id="install_dev" style="visibility: hidden">install_dev</a>
<div class="rel_section">Install<br />(development branch)</div>
<div class="rel_boxtext">
To retrieve the archive signature:
  <p class="www_code">
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -<br />
# Fingerprint:  6084 F3CF 814B 57C1 CF12  EFD5 15CF 4D18 AF4F 7421
</p><br />
We also provide meta packages to move from a major version to the other.<br />
For example, to automatically upgrade to the current major:
  <p class="www_code">
apt-get install clang lld # clang-<?=$devBranch?> lld-<?=$devBranch?> can be added to automatically install the most recent version of the package.
  </p>
<br />
To install just clang, lld and lldb (<?=$devBranch?> release):
  <p class="www_code">
apt-get install clang-<?=$devBranch?> lldb-<?=$devBranch?> lld-<?=$devBranch?>
</p>
<br />
To install all key packages:<br />
<p class="www_code">
<b># LLVM</b><br />
apt-get install libllvm-<?=$devBranch?>-ocaml-dev libllvm<?=$devBranch?> llvm-<?=$devBranch?> llvm-<?=$devBranch?>-dev llvm-<?=$devBranch?>-doc llvm-<?=$devBranch?>-examples llvm-<?=$devBranch?>-runtime<br />
<b># Clang and co</b><br />
apt-get install clang-<?=$devBranch?> clang-tools-<?=$devBranch?> clang-<?=$devBranch?>-doc libclang-common-<?=$devBranch?>-dev libclang-<?=$devBranch?>-dev libclang1-<?=$devBranch?> clang-format-<?=$devBranch?> python3-clang-<?=$devBranch?> clangd-<?=$devBranch?> clang-tidy-<?=$devBranch?><br />
<b># libfuzzer</b><br />
apt-get install libfuzzer-<?=$devBranch?>-dev<br />
<b># lldb</b><br />
apt-get install lldb-<?=$devBranch?><br />
<b># lld (linker)</b><br />
apt-get install lld-<?=$devBranch?><br />
<b># libc++</b><br />
apt-get install libc++-<?=$devBranch?>-dev libc++abi-<?=$devBranch?>-dev<br />
<b># OpenMP</b><br />
apt-get install libomp-<?=$devBranch?>-dev<br />
<b># libclc</b><br />
apt-get install libclc-<?=$devBranch?>-dev<br />
<b># libunwind</b><br />
apt-get install libunwind-<?=$devBranch?>-dev<br />
<b># mlir</b><br />
apt-get install libmlir-<?=$devBranch?>-dev mlir-<?=$devBranch?>-tools<br />
</p>

</div>

<div id="sigstore" class="rel_section">Verification using sigstore</div>

<div class="rel_boxtext">
Source, Debian tarballs and dsc files can be verified using <a href="https://sigstore.github.io/">sigstore/rekor</a>.<br />
This can be done with "rekor verify":
<p class="www_code">
file="llvm-toolchain-10_10.0.1~%2b%2b20210327072807%2bef32c611aa21-1~exp1~20210327183412.212.dsc"<br />
url="https://apt.llvm.org/unstable/pool/main/l/llvm-toolchain-10/$file"<br />
sig_file="$url.asc"<br />
wget --quiet https://apt.llvm.org/sigstore.public.key<br />
./rekor verify --rekor_server https://rekor.sigstore.dev --signature $sig_file --public-key sigstore.public.key --artifact $url<br />
echo $?<br />
</p>
<br />

Or with "rekor search":
<p class="www_code">
file="llvm-toolchain-10_10.0.1~++20210327072807+ef32c611aa21.orig.tar.xz"<br />
url="https://apt.llvm.org/unstable/pool/main/l/llvm-toolchain-10/$file"<br />
wget --quiet $url<br />
sha=$(sha256sum $file|awk '{print $1}')<br />
./rekor search --sha sha256:$sha --rekor_server https://rekor.sigstore.dev<br />
</p>

</div>

<div class="rel_section">Technical aspects</div>
<div class="rel_boxtext">
Packages are rebuilt against the trunk of the various LLVM projects.<br />
They are rebuild through a Jenkins instance:<br />
<a href="https://llvm-jenkins.debian.net">https://llvm-jenkins.debian.net</a>

<h2>Bugs</h2>
Bugs should be reported on the <a href="https://github.com/llvm/llvm-project/labels/packaging">LLVM bug tracker</a> (label: packaging).

<h2>Workflow</h2>
     Twice a day, each jenkins job will checkout the debian/ directory necessary to build the packages. The repository is available on the Debian hosting infrastructure:
<a href="https://salsa.debian.org/pkg-llvm-team/llvm-toolchain/">https://salsa.debian.org/pkg-llvm-team/llvm-toolchain/</a>.
<br />
Sources of this page, llvm.sh and others scripts are available on github:<br />
<a href="https://github.com/opencollab/llvm-jenkins.debian.net/">https://github.com/opencollab/llvm-jenkins.debian.net/</a>
<br />
In the <i>llvm-toolchain-*-source</i>, the following tasks will be performed:
<ul>
<li>upstream sources will be checkout</li>
     <li>tarballs will be created. They are named: <ul><li>llvm-toolchain_X.Y~svn123456.orig-lldb.tar.bz2</li><li>llvm-toolchain_X.Y~svn123456.orig-compiler-rt.tar.bz2</li><li>llvm-toolchain_X.Y~svn123456.orig.tar.bz2</li><li>llvm-toolchain_X.Y~svn123456.orig-clang.tar.bz2</li><li>llvm-toolchain_X.Y~svn123456.orig-polly.tar.bz2</li><li>...</li></ul></li>
<li>Debian .dsc package description is created</li>
<li>Start the jenkins job <i>llvm-toolchain-X-binary</i></li>
</ul>
Then, the job <i>llvm-toolchain-X-binary</i> will:
<ul>
<li>Create a chroot using cowbuilder or update it is already existing</li>
<li>Build all the packages</li>
<li>Launch lintian, the Debian static analyzer</li>
<li>Publish the result on the LLVM repository</li>
</ul>
Note that a <a href="https://salsa.debian.org/pkg-llvm-team/llvm-toolchain/tree/snapshot/debian/patches/">few patches</a> are applied over the
LLVM tarballs (and should be merged upstream at some point).
</div>

<div class="rel_section">Extra</div>

<div class="rel_boxtext">
With the Jenkins instance, several reports are produced:
<ul>
<li><a href="https://llvm.org/reports/scan-build/">Scan build report</a></li>
<li><a href="https://scan.coverity.com/projects/llvm">Coverity reports</a></li>
</ul>
</div>

<div class="rel_section">
Building the latest nightly snapshot
</div>

<div class="rel_boxtext">
  <a href="./building-pkgs.php">Building LLVM packages from source</a> is documented in a dedicated page.
</div>

<!--
<div class="rel_section">News</div>

<div class="rel_boxtext">
Nov 01st 2020 - Ubuntu Groovy (20.10) & Hirsute (21.04) support<br />
Nov 01st 2020 - Ubuntu Eoan disabled (EOL)<br />
Jul 15th 2020 - Snapshot becomes 12, branch 11 created<br />
Apr 14th 2020 - Ubuntu Disco disabled (EOL)<br />
Apr 06th 2020 - Ubuntu Focal (20.04) support<br />
Jan 23th 2020 - Snapshot becomes 11, branch 10 created<br />
Jan 19th 2020 - Ubuntu Cosmic disabled (EOL)<br />
Oct 30th 2019 - Ubuntu Eoan (19.10) support<br />
Aug 20th 2019 - Ubuntu Trusty disabled (EOL)<br />
Aug 01st 2019 - Snapshot becomes 10, branch 9 created<br />
Apr 07th 2019 - Debian buster (10) added<br />
Apr 06th 2019 - Debian Jessie (oldstable) <a href="https://lists.debian.org/debian-backports-announce/2018/07/msg00000.html">no longer</a> maintained<br />
Jan 19th 2019 - Branch 8 created<br />
Jan 19th 2019 - Ubuntu Disco (19.04) support<br />
Jan 19th 2019 - Artful jobs disabled (but packages still available)<br />
</div>
-->

<p style="font-size: smaller;">
     Contact: <a href="mailto:sylvestre@debian.org">Sylvestre Ledru</a>
<br />Build infra by <a href="https://www.irill.org/">IRILL</a> / Hosting by LLVM Foundation / CDN by <a href="http://www.fastly.com">Fastly</a>
</p>

</div> <!-- rel_container -->

<!--#include virtual="../attrib.incl" -->

</body>
</html>

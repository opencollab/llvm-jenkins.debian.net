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

$stableBranch="10";
$qualificationBranch="11";
$devBranch="12";
$isQualification=false;
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

  <p>The goal is to provide Debian and Ubuntu nightly packages ready to be installed with minimal impact on the distribution.<br />Packages are available for amd64 and i386 (except for recent Ubuntu) and for both the stable, <?php if ($isQualification) {?>qualification<?php } else {?>old-stable<?php } ?> and development branches (currently <?=$stableBranch?>, <?=$qualificationBranch?> and <?=$devBranch?>).</p>
<p>Packages are built using stage2 and extremely similar to the one shipping in Debian & Ubuntu.</p>
<p>The packages provide <a href="https://llvm.org/">LLVM</a> + <a href="https://clang.llvm.org/">Clang</a> + <a href="https://compiler-rt.llvm.org/">compiler-rt</a> + <a href="https://polly.llvm.org/">polly</a> + <a href="https://lldb.llvm.org/">LLDB</a> + <a href="https://lld.llvm.org/">LLD</a> + <a href="https://llvm.org/docs/LibFuzzer.html">libFuzzer</a> + <a href="https://libcxx.llvm.org/">libc++</a> + <a href="https://libcxxabi.llvm.org/">libc++abi</a> + <a href="https://openmp.llvm.org/">openmp</a></p>
</div>
<div class="rel_section">News</div>

<div class="rel_boxtext">
Nov 01th 2020 - Ubuntu Groovy (20.10) & Hirsute (21.04) support<br />
Nov 01th 2020 - Ubuntu Eoan removed (EOL)<br />
Jul 15th 2020 - Snapshot becomes 12, branch 11 created<br />
Apr 14th 2020 - Ubuntu Disco removed (EOL)<br />
Apr 06th 2020 - Ubuntu Focal (20.04) support<br />
Jan 23th 2020 - Snapshot becomes 11, branch 10 created<br />
Jan 19th 2020 - Ubuntu Cosmic removed (EOL)<br />
Oct 30th 2019 - Ubuntu Eoan (19.10) support<br />
Aug 20th 2019 - Ubuntu Trusty removed (EOL)<br />
Aug 01th 2019 - Snapshot becomes 10, branch 9 created<br />
Apr 07th 2019 - Debian Buster (10) added<br />
Apr 06th 2019 - Debian Jessie (oldstable) <a href="https://lists.debian.org/debian-backports-announce/2018/07/msg00000.html">no longer</a> maintained<br />
Jan 19th 2019 - Branch 8 created<br />
Jan 19th 2019 - Ubuntu Disco (19.04) support<br />
Jan 19th 2019 - Artful jobs disabled (but packages still available)<br />
</div>

<div class="rel_section">Automatic installation script</div>
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
</div>

<div class="rel_section">Debian</div>

<div class="rel_boxtext">

Stretch (Debian 9 - oldstable) - <small>Last update : <?=getLastUpdate("stretch");?> / Revision: <?=getLastRevision("stretch")?></small>
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

Buster (Debian 10 - stable) - <small>Last update : <?=getLastUpdate("buster");?> / Revision: <?=getLastRevision("buster")?></small>
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
<!--<a href="https://launchpad.net/~ubuntu-toolchain-r/+archive/ubuntu/test">gcc backport (ppa)</a> is necessary on Trusty (for libstdc++).<br />-->
Precise, Quantal, Raring, Saucy, Utopic, Artful, Cosmic, Eoan and Trusty are no longer supported by Ubuntu. Repo remains available<br />
<br />

Xenial LTS (16.04) - <small>Last update : <?=getLastUpdate("xenial");?> / Revision: <?=getLastRevision("xenial")?></small>
<pre>
deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial main
deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial main
# <?=$stableBranch?>

deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-<?=$stableBranch?> main
deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial-<?=$stableBranch?> main
# <?=$qualificationBranch?>

deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-<?=$qualificationBranch?> main
deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial-<?=$qualificationBranch?> main
</pre>

Bionic LTS (18.04) - <small>Last update : <?=getLastUpdate("bionic");?> / Revision: <?=getLastRevision("bionic")?></small>
<pre>
# i386 not available
deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic main
deb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic main
# <?=$stableBranch?>

deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-<?=$stableBranch?> main
deb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic-<?=$stableBranch?> main
# <?=$qualificationBranch?>

deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-<?=$qualificationBranch?> main
deb-src http://apt.llvm.org/bionic/ llvm-toolchain-bionic-<?=$qualificationBranch?> main
</pre>

Focal (20.04) LTS - <small>Last update : <?=getLastUpdate("focal");?> / Revision: <?=getLastRevision("focal")?></small>
<pre>
# i386 not available
deb http://apt.llvm.org/focal/ llvm-toolchain-focal main
deb-src http://apt.llvm.org/focal/ llvm-toolchain-focal main
# <?=$stableBranch?>

deb http://apt.llvm.org/focal/ llvm-toolchain-focal-<?=$stableBranch?> main
deb-src http://apt.llvm.org/focal/ llvm-toolchain-focal-<?=$stableBranch?> main
# <?=$qualificationBranch?>

deb http://apt.llvm.org/focal/ llvm-toolchain-focal-<?=$qualificationBranch?> main
deb-src http://apt.llvm.org/focal/ llvm-toolchain-focal-<?=$qualificationBranch?> main

</pre>
Groovy (20.10) - <small>Last update : <?=getLastUpdate("groovy");?> / Revision: <?=getLastRevision("groovy")?></small>
<pre>
# i386 not available
deb http://apt.llvm.org/groovy/ llvm-toolchain-groovy main
deb-src http://apt.llvm.org/groovy/ llvm-toolchain-groovy main
# <?=$stableBranch?>

deb http://apt.llvm.org/groovy/ llvm-toolchain-groovy-<?=$stableBranch?> main
deb-src http://apt.llvm.org/groovy/ llvm-toolchain-groovy-<?=$stableBranch?> main
# <?=$qualificationBranch?>

deb http://apt.llvm.org/groovy/ llvm-toolchain-groovy-<?=$qualificationBranch?> main
deb-src http://apt.llvm.org/groovy/ llvm-toolchain-groovy-<?=$qualificationBranch?> main
</pre>

Hirsute (21.04) - <small>Last update : <?=getLastUpdate("hirsute");?> / Revision: <?=getLastRevision("hirsute")?></small>
<pre>
# i386 not available
deb http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute main
deb-src http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute main
# <?=$stableBranch?>

deb http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute-<?=$stableBranch?> main
deb-src http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute-<?=$stableBranch?> main
# <?=$qualificationBranch?>

deb http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute-<?=$qualificationBranch?> main
deb-src http://apt.llvm.org/hirsute/ llvm-toolchain-hirsute-<?=$qualificationBranch?> main
</pre>

</div>
<a href="#" id="default_pkg" style="visibility: hidden">default_pkg</a>
<div class="rel_section">Default packages</div>
<div class="rel_boxtext">
          To make sure always the most recent versions of the packages are installed, we are providing some default packages.<br />To install all of them (currently version <?=$devBranch?>):
<p class="www_code">
        apt-get install clang-format clang-tidy clang-tools clang clangd libc++-dev libc++1 libc++abi-dev libc++abi1 libclang-dev libclang1 liblldb-dev libllvm-ocaml-dev libomp-dev libomp5 lld lldb llvm-dev llvm-runtime llvm python-clang
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
apt-get install clang-<?=$stableBranch?> clang-tools-<?=$stableBranch?> clang-<?=$stableBranch?>-doc libclang-common-<?=$stableBranch?>-dev libclang-<?=$stableBranch?>-dev libclang1-<?=$stableBranch?> clang-format-<?=$stableBranch?> python-clang-<?=$stableBranch?> clangd-<?=$stableBranch?> <br />
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
apt-get install clang-<?=$qualificationBranch?> clang-tools-<?=$qualificationBranch?> clang-<?=$qualificationBranch?>-doc libclang-common-<?=$qualificationBranch?>-dev libclang-<?=$qualificationBranch?>-dev libclang1-<?=$qualificationBranch?> clang-format-<?=$qualificationBranch?> python-clang-<?=$qualificationBranch?> clangd-<?=$qualificationBranch?><br />
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
apt-get install clang-<?=$devBranch?> clang-tools-<?=$devBranch?> clang-<?=$devBranch?>-doc libclang-common-<?=$devBranch?>-dev libclang-<?=$devBranch?>-dev libclang1-<?=$devBranch?> clang-format-<?=$devBranch?> python-clang-<?=$devBranch?> clangd-<?=$devBranch?><br />
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
</p>

</div>
<div class="rel_section">Technical aspects</div>
<div class="rel_boxtext">
Packages are rebuilt against the trunk of the various LLVM projects.<br />
     They are rebuild through a Jenkins instance:<br />
<a href="https://llvm-jenkins.debian.net">https://llvm-jenkins.debian.net</a>

<h2>Bugs</h2>
Bugs should be reported on the <a href="https://llvm.org/bugs/enter_bug.cgi?product=Packaging">LLVM bug tracker</a> (deb packages).

<h2>Workflow</h2>
     Twice a day, each jenkins job will checkout the debian/ directory necessary to build the packages. The repository is available on the Debian hosting infrastructure:
<a href="https://salsa.debian.org/pkg-llvm-team/llvm-toolchain/">https://salsa.debian.org/pkg-llvm-team/llvm-toolchain/</a>.

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
<li><a href="https://llvm.org/reports/coverage/">Code coverage</a></li>
<li><a href="https://scan.coverity.com/projects/llvm">Coverity reports</a></li>
</ul>
</div>

<div class="rel_section">
Building the latest nightly snapshot
</div>

<div class="rel_boxtext">
  <a href="./building-pkgs.php">Building LLVM packages from source</a> is documented in a dedicated page.
</div>

<p style="font-size: smaller;">
     Contact: <a href="mailto:sylvestre@debian.org">Sylvestre Ledru</a>
<br />Build infra by <a href="https://www.irill.org/">IRILL</a> / Hosting by LLVM Foundation / CDN by <a href="http://www.fastly.com">Fastly</a>
</p>

</div> <!-- rel_container -->

<!--#include virtual="../attrib.incl" -->

</body>
</html>

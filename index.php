<?php
function getLastUpdate($version) {
   $base="/data/apt/www";
   if ($version!="unstable") {
     $fullpath=$base."/${version}/dists/llvm-toolchain-{$version}/Release";
   } else {
     $fullpath=$base."/${version}/dists/llvm-toolchain/Release";
   }
   $handle = fopen($fullpath, "r");
   $contents = fread($handle, filesize($fullpath));
   preg_match("/Date: (.*)/",$contents,$matches);
   return $matches[1];
}
function getLastRevision($version) {
   $base="/data/apt/www";
   if ($version!="unstable") {
     $fullpath=$base."/${version}/dists/llvm-toolchain-{$version}/main/binary-amd64/Packages";
   } else {
     $fullpath=$base."/${version}/dists/llvm-toolchain/main/binary-amd64/Packages";
   }
   $handle = fopen($fullpath, "r");
   $contents = fread($handle, filesize($fullpath));
   preg_match("/Version: .*~svn(.*)-/",$contents,$matches);
   return $matches[1];
}

$stableBranch="5.0";
$qualificationBranch="6.0";
$devBranch="7";

?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
                      "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <title>LLVM Debian/Ubuntu nightly packages</title>
  <link rel="stylesheet" type="text/css" href="//llvm.org/llvm.css">
</head>
<body>

<div class="rel_title">
  LLVM Debian/Ubuntu nightly packages
</div>

<div class="rel_container">

<div class="rel_section">Download</div>

<div class="rel_boxtext">

  <p>The goal is to provide Debian and Ubuntu nightly packages ready to be installed with minimal impact on the distribution.<br />Packages are available for amd64 and i386 (except for recent Ubuntu) and for both the stable, qualification and development branches (currently <?=$stableBranch?>, <?=$qualificationBranch?> and <?=$devBranch?>).</p>
<p>The packages provide <a href="http://llvm.org/">LLVM</a> + <a href="http://clang.llvm.org/">Clang</a> + <a href="http://compiler-rt.llvm.org/">compiler-rt</a> + <a href="http://polly.llvm.org/">polly</a> + <a href="http://lldb.llvm.org/">LLDB</a> + <a href="http://lld.llvm.org/">LLD</a> + <a href="http://llvm.org/docs/LibFuzzer.html">libFuzzer</a></p>
</div>

<div class="rel_section">Debian</div>

<div class="rel_boxtext">

Jessie (Debian old stable) - <small>Last update : <?=getLastUpdate("jessie");?> / Revision: <?=getLastRevision("jessie")?></small>
<pre>
deb http://apt.llvm.org/jessie/ llvm-toolchain-jessie main
deb-src http://apt.llvm.org/jessie/ llvm-toolchain-jessie main
# <?=$stableBranch?> 
deb http://apt.llvm.org/jessie/ llvm-toolchain-jessie-<?=$stableBranch?> main
deb-src http://apt.llvm.org/jessie/ llvm-toolchain-jessie-<?=$stableBranch?> main
# <?=$qualificationBranch?> 
deb http://apt.llvm.org/jessie/ llvm-toolchain-jessie-<?=$qualificationBranch?> main
deb-src http://apt.llvm.org/jessie/ llvm-toolchain-jessie-<?=$qualificationBranch?> main
</pre>

Stretch (Debian stable) - <small>Last update : <?=getLastUpdate("stretch");?> / Revision: <?=getLastRevision("stretch")?></small>
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
<a href="https://launchpad.net/~ubuntu-toolchain-r/+archive/ubuntu/test">gcc backport (ppa)</a> is necessary on Trusty (for libstdc++).<br />
Precise, Quantal, Raring, Saucy and Utopic are no longer supported by Ubuntu.<br />
<br />

     Trusty (14.04) - <small>Last update : <?=getLastUpdate("trusty");?> / Revision: <?=getLastRevision("trusty")?></small>
<pre>
deb http://apt.llvm.org/trusty/ llvm-toolchain-trusty main
deb-src http://apt.llvm.org/trusty/ llvm-toolchain-trusty main
# <?=$stableBranch?> 
deb http://apt.llvm.org/trusty/ llvm-toolchain-trusty-<?=$stableBranch?> main
deb-src http://apt.llvm.org/trusty/ llvm-toolchain-trusty-<?=$stableBranch?> main
# <?=$qualificationBranch?> 
deb http://apt.llvm.org/trusty/ llvm-toolchain-trusty-<?=$qualificationBranch?> main
deb-src http://apt.llvm.org/trusty/ llvm-toolchain-trusty-<?=$qualificationBranch?> main

# Also add the following for the appropriate libstdc++
deb http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu trusty main
</pre>

Xenial (16.04) - <small>Last update : <?=getLastUpdate("xenial");?> / Revision: <?=getLastRevision("xenial")?></small>
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

Zesty (17.04) - <small>Last update : <?=getLastUpdate("zesty");?> / Revision: <?=getLastRevision("zesty")?></small>
<pre>
deb http://apt.llvm.org/zesty/ llvm-toolchain-zesty main
deb-src http://apt.llvm.org/zesty/ llvm-toolchain-zesty main
# <?=$stableBranch?>

deb http://apt.llvm.org/zesty/ llvm-toolchain-zesty-<?=$stableBranch?> main
deb-src http://apt.llvm.org/zesty/ llvm-toolchain-zesty-<?=$stableBranch?> main
# <?=$qualificationBranch?>

deb http://apt.llvm.org/zesty/ llvm-toolchain-zesty-<?=$qualificationBranch?> main
deb-src http://apt.llvm.org/zesty/ llvm-toolchain-zesty-<?=$qualificationBranch?> main
</pre>

Artful (17.10) - <small>Last update : <?=getLastUpdate("artful");?> / Revision: <?=getLastRevision("artful")?></small>
<pre>
# i386 not available
deb http://apt.llvm.org/artful/ llvm-toolchain-artful main
deb-src http://apt.llvm.org/artful/ llvm-toolchain-artful main
# <?=$stableBranch?>

deb http://apt.llvm.org/artful/ llvm-toolchain-artful-<?=$stableBranch?> main
deb-src http://apt.llvm.org/artful/ llvm-toolchain-artful-<?=$stableBranch?> main
# <?=$qualificationBranch?>

deb http://apt.llvm.org/artful/ llvm-toolchain-artful-<?=$qualificationBranch?> main
deb-src http://apt.llvm.org/artful/ llvm-toolchain-artful-<?=$qualificationBranch?> main
</pre>

Bionic (18.04) - <small>Last update : <?=getLastUpdate("bionic");?> / Revision: <?=getLastRevision("bionic")?></small>
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
</div>

<div class="rel_section">Install<br />(stable branch)</div>
<div class="rel_boxtext">
To retrieve the archive signature:
  <p class="www_code">
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -<br />
# Fingerprint:  6084 F3CF 814B 57C1 CF12  EFD5 15CF 4D18 AF4F 7421
</p><br />

To install just clang and lldb (<?=$stableBranch?> release):
  <p class="www_code">
apt-get install clang-<?=$stableBranch?> lldb-<?=$stableBranch?>
</p>
<br />
To install all packages:<br />
<p class="www_code">

apt-get install clang-<?=$stableBranch?> clang-tools-<?=$stableBranch?> clang-<?=$stableBranch?>-doc libclang-common-<?=$stableBranch?>-dev libclang-<?=$stableBranch?>-dev libclang1-<?=$stableBranch?> libclang1-<?=$stableBranch?>-dbg libllvm-<?=$stableBranch?>-ocaml-dev libllvm<?=$stableBranch?> libllvm<?=$stableBranch?>-dbg lldb-<?=$stableBranch?> llvm-<?=$stableBranch?> llvm-<?=$stableBranch?>-dev llvm-<?=$stableBranch?>-doc llvm-<?=$stableBranch?>-examples llvm-<?=$stableBranch?>-runtime clang-format-<?=$stableBranch?> python-clang-<?=$stableBranch?> libfuzzer-<?=$stableBranch?>-dev
</p>
</div>

<div class="rel_section">Install<br />(qualification branch)</div>
<div class="rel_boxtext">
To retrieve the archive signature:
  <p class="www_code">
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -<br />
# Fingerprint:  6084 F3CF 814B 57C1 CF12  EFD5 15CF 4D18 AF4F 7421
</p><br />

To install just clang and lldb (<?=$qualificationBranch?> release):
  <p class="www_code">
apt-get install clang-<?=$qualificationBranch?> lldb-<?=$qualificationBranch?> lld-<?=$qualificationBranch?>
</p>
<br />
To install all packages:<br />
<p class="www_code">

apt-get install clang-<?=$qualificationBranch?> clang-tools-<?=$qualificationBranch?> clang-<?=$qualificationBranch?>-doc libclang-common-<?=$qualificationBranch?>-dev libclang-<?=$qualificationBranch?>-dev libclang1-<?=$qualificationBranch?> libclang1-<?=$qualificationBranch?>-dbg libllvm-<?=$qualificationBranch?>-ocaml-dev libllvm<?=$qualificationBranch?> libllvm<?=$qualificationBranch?>-dbg lldb-<?=$qualificationBranch?> llvm-<?=$qualificationBranch?> llvm-<?=$qualificationBranch?>-dev llvm-<?=$qualificationBranch?>-doc llvm-<?=$qualificationBranch?>-examples llvm-<?=$qualificationBranch?>-runtime clang-format-<?=$qualificationBranch?> python-clang-<?=$qualificationBranch?> lldb-<?=$qualificationBranch?>-dev lld-<?=$qualificationBranch?> libfuzzer-<?=$qualificationBranch?>-dev
</p>

</div>


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
To install all packages:<br />
<p class="www_code">

apt-get install clang-<?=$devBranch?> clang-tools-<?=$devBranch?> clang-<?=$devBranch?>-doc libclang-common-<?=$devBranch?>-dev libclang-<?=$devBranch?>-dev libclang1-<?=$devBranch?> libclang1-<?=$devBranch?>-dbg libllvm-<?=$devBranch?>-ocaml-dev libllvm<?=$devBranch?> libllvm<?=$devBranch?>-dbg lldb-<?=$devBranch?> llvm-<?=$devBranch?> llvm-<?=$devBranch?>-dev llvm-<?=$devBranch?>-doc llvm-<?=$devBranch?>-examples llvm-<?=$devBranch?>-runtime clang-format-<?=$devBranch?> python-clang-<?=$devBranch?> liblldb-<?=$devBranch?>-dbg lld-<?=$devBranch?> libfuzzer-<?=$devBranch?>-dev
</p>

</div>
<div class="rel_section">Technical aspects</div>
<div class="rel_boxtext">
Packages are rebuilt against the trunk of the various LLVM projects.<br />
     They are rebuild through a Jenkins instance:<br />
<a href="https://llvm-jenkins.debian.net">https://llvm-jenkins.debian.net</a>

<h2>Bugs</h2>
Bugs should be reported on the <a href="http://llvm.org/bugs/enter_bug.cgi?product=Packaging">LLVM bug tracker</a> (deb packages).

<h2>Workflow</h2>
     Twice a day, each jenkins job will checkout the debian/ directory necessary to build the packages. The repository is available on the Debian hosting infrastructure:
<a href="https://salsa.debian.org/pkg-llvm-team/llvm-toolchain/">https://salsa.debian.org/pkg-llvm-team/llvm-toolchain/</a>.

     In the <i>llvm-toolchain-*-source</i>, the following tasks will be performed:
<ul>
<li>upstream sources will be checkout</li>
     <li>tarballs will be created. They are named: <ul><li>llvm-toolchain_X.Y~svn123456.orig-lldb.tar.bz2</li><li>llvm-toolchain_X.Y~svn123456.orig-compiler-rt.tar.bz2</li><li>llvm-toolchain_X.Y~svn123456.orig.tar.bz2</li><li>llvm-toolchain_X.Y~svn123456.orig-clang.tar.bz2</li><li>llvm-toolchain_X.Y~svn123456.orig-polly.tar.bz2</li></ul></li>
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
<li><a href="http://llvm.org/reports/scan-build/">Scan build report</a></li>
<li><a href="http://llvm.org/reports/coverage/">Code coverage</a></li>
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
Changes:

- Oct 6th 2015:
  * Debian wheezy removed
  * Ubuntu Utopic removed (EOL)
  * Fix a typo in vivid

- Oct 13th 2015:
  * Add wily

- Feb 14th 2016:
  * 3.8 added / snapshot moved to 3.9
  * Ubuntu vivid removed (EOL)
  * switch to cmake for 3.8 & 3.9
  * Wily added

- Jul 20th 2016:
  * 3.7 dead, 4.0 enabled

- Jan 15 2017
  * 3.8 dead, 5.0 enabled
  * zesty added
  * lld added

- May 23 2017
  * artful enabled

- July 28 2017
  * 3.9 is dead, 6.0 enabled
  * stretch added
  * precise, wily & yakkety removed from the webpage
  * artful added to the webpage

- Jan 22th 2018
  * 4.0 is dead, 7 enavbled
  * Moved from X.0 => X
  * Bionic enabled
-->
<p style="font-size: smaller;">
     Contact: <a href="mailto:sylvestre@debian.org">Sylvestre Ledru</a>
<br />Build infra by <a href="http://www.irill.org/">IRILL</a> / Hosting by LLVM Foundation / CDN by <a href="http://www.fastly.com">Fastly</a>
</p>

</div> <!-- rel_container -->

<!--#include virtual="../attrib.incl" -->

</body>
</html>

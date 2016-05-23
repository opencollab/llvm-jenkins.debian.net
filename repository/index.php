<?
function getLastUpdate($version) {
   $base="/home/apt/www/";
   if ($version!="unstable") {
     $fullpath=$base."/${version}/dists/llvm-toolchain-{$version}/InRelease";
   } else {
     $fullpath=$base."/${version}/dists/llvm-toolchain/InRelease";
   }

   $handle = fopen($fullpath, "r");
   $contents = fread($handle, filesize($fullpath));
   preg_match("/Date: (.*)/",$contents,$matches);
   return $matches[1];
}
function getLastRevision($version) {
   $base="/home/apt/www/";
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

$stableBranch="3.6";
$qualificationBranch="3.7";
$devBranch="3.8";

?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
                      "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <title>LLVM Debian/Ubuntu nightly packages</title>
  <link rel="stylesheet" type="text/css" href="../llvm.css">
</head>
<body>

<div class="rel_title">
  LLVM Debian/Ubuntu nightly packages
</div>

<div class="rel_container">

<div class="rel_section">Download</div>

<div class="rel_boxtext">

  <p>The goal is to provide Debian and Ubuntu nightly packages ready to be installed with minimal impact on the distribution.<br />Packages are available for amd64 and i386 and for both the stable and development branches (currently <?=$stableBranch?> and <?=$devBranch?>).</p>
<p>The packages provide <a href="http://llvm.org/">LLVM</a> + <a href="http://clang.llvm.org/">Clang</a> + <a href="http://compiler-rt.llvm.org/">compiler-rt</a> + <a href="http://polly.llvm.org/">polly</a> + <a href="http://lldb.llvm.org/">LLDB</a></p>
</div>

<div class="rel_section">Debian</div>

<div class="rel_boxtext">

Jessie (Debian stable) - <small>Last update : <?=getLastUpdate("jessie");?> / Revision: <?=getLastRevision("jessie")?></small>
<pre>
deb http://llvm.org/apt/jessie/ llvm-toolchain-jessie main
deb-src http://llvm.org/apt/jessie/ llvm-toolchain-jessie main
# <?=$stableBranch?> 
deb http://llvm.org/apt/jessie/ llvm-toolchain-jessie-<?=$stableBranch?> main
deb-src http://llvm.org/apt/jessie/ llvm-toolchain-jessie-<?=$stableBranch?> main
# <?=$qualificationBranch?> 
deb http://llvm.org/apt/jessie/ llvm-toolchain-jessie-<?=$qualificationBranch?> main
deb-src http://llvm.org/apt/jessie/ llvm-toolchain-jessie-<?=$qualificationBranch?> main
</pre>

sid (unstable) - <small>Last update : <?=getLastUpdate("unstable");?> / Revision: <?=getLastRevision("unstable")?></small>
<!--# Need Debian experimental too-->
<pre>
deb http://llvm.org/apt/unstable/ llvm-toolchain main
deb-src http://llvm.org/apt/unstable/ llvm-toolchain main
# <?=$stableBranch?> 
deb http://llvm.org/apt/unstable/ llvm-toolchain-<?=$stableBranch?> main
deb-src http://llvm.org/apt/unstable/ llvm-toolchain-<?=$stableBranch?> main
# <?=$qualificationBranch?> 
deb http://llvm.org/apt/unstable/ llvm-toolchain-<?=$qualificationBranch?> main
deb-src http://llvm.org/apt/unstable/ llvm-toolchain-<?=$qualificationBranch?> main

</pre>

</div>
<div class="rel_section">Ubuntu</div>
<div class="rel_boxtext">
<a href="https://launchpad.net/~ubuntu-toolchain-r/+archive/ubuntu/test">gcc backport (ppa)</a> is necessary on Precise (for libstdc++).<br />
Quantal, Raring, Saucy and Utopic are no longer supported by Ubuntu.<br />
<br />
     Precise (12.04) - <small>Last update : <?=getLastUpdate("precise");?> / Revision: <?=getLastRevision("precise")?></small>
<pre>
deb http://llvm.org/apt/precise/ llvm-toolchain-precise main
deb-src http://llvm.org/apt/precise/ llvm-toolchain-precise main
# <?=$stableBranch?> 
deb http://llvm.org/apt/precise/ llvm-toolchain-precise-<?=$stableBranch?> main
deb-src http://llvm.org/apt/precise/ llvm-toolchain-precise-<?=$stableBranch?> main
# <?=$qualificationBranch?> 
deb http://llvm.org/apt/precise/ llvm-toolchain-precise-<?=$qualificationBranch?> main
deb-src http://llvm.org/apt/precise/ llvm-toolchain-precise-<?=$qualificationBranch?> main

# Common
deb http://ppa.launchpad.net/ubuntu-toolchain-r/test/ubuntu precise main
</pre>

     Trusty (14.04) - <small>Last update : <?=getLastUpdate("trusty");?> / Revision: <?=getLastRevision("trusty")?></small>
<pre>
deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty main
deb-src http://llvm.org/apt/trusty/ llvm-toolchain-trusty main
# <?=$stableBranch?> 
deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-<?=$stableBranch?> main
deb-src http://llvm.org/apt/trusty/ llvm-toolchain-trusty-<?=$stableBranch?> main
# <?=$qualificationBranch?> 
deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-<?=$qualificationBranch?> main
deb-src http://llvm.org/apt/trusty/ llvm-toolchain-trusty-<?=$qualificationBranch?> main

</pre>

     Vivid (15.04) - <small>Last update : <?=getLastUpdate("vivid");?> / Revision: <?=getLastRevision("vivid")?></small>
<pre>
deb http://llvm.org/apt/vivid/ llvm-toolchain-vivid main
deb-src http://llvm.org/apt/vivid/ llvm-toolchain-vivid main
# <?=$stableBranch?> 
deb http://llvm.org/apt/vivid/ llvm-toolchain-vivid-<?=$stableBranch?> main
deb-src http://llvm.org/apt/vivid/ llvm-toolchain-vivid-<?=$stableBranch?> main
# <?=$qualificationBranch?> 
deb http://llvm.org/apt/vivid/ llvm-toolchain-vivid-<?=$qualificationBranch?> main
deb-src http://llvm.org/apt/vivid/ llvm-toolchain-vivid-<?=$qualificationBranch?> main
</pre>

Willy (15.10) - <small>Last update : <?=getLastUpdate("wily");?> / Revision: <?=getLastRevision("wily")?></small>
<pre>
deb http://llvm.org/apt/wily/ llvm-toolchain-wily main
deb-src http://llvm.org/apt/wily/ llvm-toolchain-wily main
# <?=$stableBranch?> 
deb http://llvm.org/apt/wily/ llvm-toolchain-wily-<?=$stableBranch?> main
deb-src http://llvm.org/apt/wily/ llvm-toolchain-wily-<?=$stableBranch?> main
# <?=$qualificationBranch?> 
deb http://llvm.org/apt/wily/ llvm-toolchain-wily-<?=$qualificationBranch?> main
deb-src http://llvm.org/apt/wily/ llvm-toolchain-wily-<?=$qualificationBranch?> main
</pre>


</div>

<div class="rel_section">Install<br />(stable branch)</div>
<div class="rel_boxtext">
To retrieve the archive signature:
  <p class="www_code">
wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key|sudo apt-key add -<br />
</p><br />

To install just clang and lldb (<?=$stableBranch?> release):
  <p class="www_code">
apt-get install clang-<?=$stableBranch?> lldb-<?=$stableBranch?>
</p>
<br />
To install all packages:<br />
<p class="www_code">

apt-get install clang-<?=$stableBranch?> clang-<?=$stableBranch?>-doc libclang-common-<?=$stableBranch?>-dev libclang-<?=$stableBranch?>-dev libclang1-<?=$stableBranch?> libclang1-<?=$stableBranch?>-dbg libllvm-<?=$stableBranch?>-ocaml-dev libllvm<?=$stableBranch?> libllvm<?=$stableBranch?>-dbg lldb-<?=$stableBranch?> llvm-<?=$stableBranch?> llvm-<?=$stableBranch?>-dev llvm-<?=$stableBranch?>-doc llvm-<?=$stableBranch?>-examples llvm-<?=$stableBranch?>-runtime clang-modernize-<?=$stableBranch?> clang-format-<?=$stableBranch?> python-clang-<?=$stableBranch?> lldb-<?=$stableBranch?>-dev
</p>
</div>

<div class="rel_section">Install<br />(qualification branch)</div>
<div class="rel_boxtext">
To retrieve the archive signature:
  <p class="www_code">
wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key|sudo apt-key add -<br />
</p><br />

To install just clang and lldb (<?=$qualificationBranch?> release):
  <p class="www_code">
apt-get install clang-<?=$qualificationBranch?> lldb-<?=$qualificationBranch?>
</p>
<br />
To install all packages:<br />
<p class="www_code">

apt-get install clang-<?=$qualificationBranch?> clang-<?=$qualificationBranch?>-doc libclang-common-<?=$qualificationBranch?>-dev libclang-<?=$qualificationBranch?>-dev libclang1-<?=$qualificationBranch?> libclang1-<?=$qualificationBranch?>-dbg libllvm-<?=$qualificationBranch?>-ocaml-dev libllvm<?=$qualificationBranch?> libllvm<?=$qualificationBranch?>-dbg lldb-<?=$qualificationBranch?> llvm-<?=$qualificationBranch?> llvm-<?=$qualificationBranch?>-dev llvm-<?=$qualificationBranch?>-doc llvm-<?=$qualificationBranch?>-examples llvm-<?=$qualificationBranch?>-runtime clang-modernize-<?=$qualificationBranch?> clang-format-<?=$qualificationBranch?> python-clang-<?=$qualificationBranch?> lldb-<?=$qualificationBranch?>-dev liblldb-<?=$qualificationBranch?>-dbg
</p>

</div>


<div class="rel_section">Install<br />(development branch)</div>
<div class="rel_boxtext">
To retrieve the archive signature:
  <p class="www_code">
wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key|sudo apt-key add -<br />
</p><br />

To install just clang and lldb (<?=$devBranch?> release):
  <p class="www_code">
apt-get install clang-<?=$devBranch?> lldb-<?=$devBranch?>
</p>
<br />
To install all packages:<br />
<p class="www_code">

apt-get install clang-<?=$devBranch?> clang-<?=$devBranch?>-doc libclang-common-<?=$devBranch?>-dev libclang-<?=$devBranch?>-dev libclang1-<?=$devBranch?> libclang1-<?=$devBranch?>-dbg libllvm-<?=$devBranch?>-ocaml-dev libllvm<?=$devBranch?> libllvm<?=$devBranch?>-dbg lldb-<?=$devBranch?> llvm-<?=$devBranch?> llvm-<?=$devBranch?>-dev llvm-<?=$devBranch?>-doc llvm-<?=$devBranch?>-examples llvm-<?=$devBranch?>-runtime clang-modernize-<?=$devBranch?> clang-format-<?=$devBranch?> python-clang-<?=$devBranch?> lldb-<?=$devBranch?>-dev liblldb-<?=$devBranch?>-dbg
</p>

</div>
<div class="rel_section">Technical aspects</div>
<div class="rel_boxtext">
Packages are rebuilt against the trunk of the various LLVM projects.<br />
     They are rebuild through a Jenkins instance:<br />
<a href="http://llvm-jenkins.debian.net">http://llvm-jenkins.debian.net</a>

<h2>Bugs</h2>
Bugs should be reported on the <a href="http://llvm.org/bugs/enter_bug.cgi?product=Packaging">LLVM bug tracker</a> (deb packages).

<h2>Workflow</h2>
     Twice a day, each jenkins job will checkout the debian/ directory necessary to build the packages. The repository is available on the Debian hosting infrastructure:
<a href="http://anonscm.debian.org/viewvc/pkg-llvm/llvm-toolchain/branches/">http://anonscm.debian.org/viewvc/pkg-llvm/llvm-toolchain/branches/</a>.

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
Note that a <a href="http://anonscm.debian.org/viewvc/pkg-llvm/llvm-toolchain/branches/snapshot/debian/patches/">few patches</a> are applied over the
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
<p>The latest nightly snapshot can be built on your own machine with the following steps. First, ensure you add to your apt.sources the <a href="http://llvm.org/apt">nightly repositories for your distribution</a>.</p>
<p>Use apt-get to retrieve the sources of the llvm-toolchain-snapshot package,</p>
<p class="www_code"> $ mkdir build/ &amp;&amp; cd build/ <br />
 $ apt-get source llvm-toolchain-snapshot </p>
<p>This should download all the original snapshot tarballs, and create a directory named llvm-toolchain-snapshot-3.9~svn270412. Depending on the last update of the jenkins nightly builder, the snapshot version number and svn release will vary.</p>
<p>Then install the build dependencies,</p>
<p class="www_code"> $ sudo apt-get build-dep llvm-toolchain-snapshot </p>
<p>Once everything is ready, enter the directory and build the package,</p>
<p class="www_code"> $ cd llvm-toolchain-snapshot-3.9~svn270412/ <br />
 $ debuild -us -uc -b</p>
</div>

<div class="rel_section">
Building a snapshot package by hand
</div>

<div class="rel_boxtext">
<p>In some cases you may want to build a snapshot package manually. For example to debug the debian package scripts, or to build a package for a specific development branch. In that scenario, follow the following steps:</p>
<ol style="list-style-type: decimal">
<li><p>Checkout the llvm-toolchain source package.</p>
<p>The source package is maintained in SVN, you can retrieve it using the svn checkout command,</p>
<p class="www_code">$ svn co svn://anonscm.debian.org/svn/pkg-llvm/llvm-toolchain/</p></li>
<li><p>Retrieve the latest snapshot and create original tarballs.</p>
<p>From the branches/ directory run the orig-tar.sh script,</p>
<p class="www_code">$ sh snapshot/debian/orig-tar.sh</p>
<p>which will retrieve the latest version for each LLVM subproject (llvm, clang, lldb, etc.) from the main development SVN and repack it as a set of tarballs.</p></li>
<li><p>Unpack the original tarballs and apply quilt debian patches.</p>
<p>From the branches/ directory run the unpack.sh script,</p>
<p class="www_code">$ sh unpack.sh</p>
<p>which will unpack the source tree inside a new directory such as branches/llvm-toolchain-snapshot_3.9~svn268942. Depending on the current snapshot version number and svn release, the directory name will be different. Quilt patches will then be applied.</p></li>
<li><p>Build the binary packages using,</p>
<p class="www_code">$ fakeroot debian/rules binary</p>
<p>When debugging, successive builds can be recompiled faster by using tools such as ccache (PATH=/usr/lib/ccache:$PATH fakeroot debian/rules binary).</p></li>
</ol>
<h2 id="retrieving-a-specific-branch-or-release-candidate-with-orig-tar.sh">Retrieving a specific branch or release candidate with orig-tar.sh</h2>
<p>When using orig-tar.sh, if you need to retrieve a specific branch, you can pass the branch name as the first argument. For example, to get the 3.8 release branch at http://llvm.org/svn/llvm-project/{llvm,...}/branches/release_38 you should use,</p>
<p class="www_code">$ sh 3.8/debian/orig-tar.sh release_38</p>
<p>To retrieve a specific release candidate, you can pass the branch name as the first argument, and the tag rc number as the second argument. For example, to get the 3.8.0 release candidate rc3 at http://llvm.org/svn/llvm-project/{llvm,...}/tags/RELEASE_380/rc3 you should use,</p>
<p class="www_code">$ sh 3.8/debian/orig-tar.sh RELEASE_380 rc3</p>
<h2 id="organization-of-the-repository">Organization of the repository</h2>
<p>The debian package for each LLVM point release is maintained as a separate SVN branch in the branches/ directory. For example, the 3.8 release lives at branches/3.8.</p>
<p>The current snapshot release is maintained at branches/snapshot.</p>
<h2 id="additional-maintainer-scripts">Additional maintainer scripts</h2>
<p>The script qualify-clang.sh that is found at the SVN root should be used to quickly test a newly built package. It runs a short set of sanity-check tests.</p>
<p>The script releases/snapshot/debian/prepare-new-release.sh is used when preparing a new point release. It automatically replaces version numbers in various files of the package.</p>
</div>

<!--
Changes:

- Oct 6th 2015:
  * Debian wheezy removed
  * Ubuntu Utopic removed (EOF)
  * Fix a typo in vivid

- Oct 13th 2015:
  * Add wily

-->
<p style="font-size: smaller;">
     Contact: <a href="mailto:sylvestre@debian.org">Sylvestre Ledru</a>
<br />Hosting by <a href="http://www.irill.org/">IRILL</a>
</p>

</div> <!-- rel_container -->

<!--#include virtual="../attrib.incl" -->

</body>
</html>

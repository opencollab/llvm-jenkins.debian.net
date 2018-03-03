<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
                      "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
  <title>How to build LLVM Debian/Ubuntu packages from source?</title>
  <link rel="stylesheet" type="text/css" href="http://llvm.org/llvm.css">
</head>
<body>

<div class="rel_title">
  How to build LLVM Debian/Ubuntu packages from source?
</div>

<div class="rel_container">
<div class="rel_section">
Building the latest nightly snapshot
</div>

<div class="rel_boxtext">
  <p>The latest nightly snapshot can be built with the following steps. First,
  ensure you add to your <i>apt.sources</i> the <a href="./">nightly
  repositories for your distribution</a>.</p>

  <p>Use apt-get to retrieve the sources of the llvm-toolchain-snapshot
  package,</p>

  <p class="www_code">
    $ mkdir build/ &amp;&amp; cd build/ <br />
    $ apt-get source llvm-toolchain-snapshot
  </p>

  <p>This should download all the original snapshot tarballs, and create a
  directory named llvm-toolchain-snapshot-3.9~svn270412. Depending on the last
  update of the jenkins nightly builder, the snapshot version number and svn
  release will vary.</p>

  <p>Then install the build dependencies,</p>
  <p class="www_code"> $ sudo apt-get build-dep llvm-toolchain-snapshot </p>

  <p> On older versions of Ubuntu, some build dependencies cannot be satisfied
  because the required gcc versions are missing. To fix this issue you should add
  the <a href="https://launchpad.net/~ubuntu-toolchain-r/+archive/ubuntu/ppa">Ubuntu
  Toolchain PPA</a> to your system before executing the above command.</p>

  <p>Once everything is ready, enter the directory and build the package,</p>

  <p class="www_code">
    $ cd llvm-toolchain-snapshot-3.9~svn270412/ <br />
    $ debuild -us -uc -b
  </p>
</div>

<div class="rel_section">
Building a snapshot package by hand
</div>

<div class="rel_boxtext">
  <p>In some cases you may want to build a snapshot package manually. For example
  to debug the Debian package scripts, or to build a package for a specific
  development branch. In that scenario, follow the following steps:</p>

  <ol>
    <li><p>Clone the llvm-toolchain source package.</p>
      <p>The source package is maintained in git, you can retrieve it using the
        <i>debcheckout</i> command,</p>
      <p class="www_code">
        $ git clone https://salsa.debian.org/pkg-llvm-team/llvm-toolchain.git -b snapshot snapshot
      </p></li>
    <li><p>Retrieve the latest snapshot and create original tarballs.</p>
      <p>Run the orig-tar.sh script,</p>
      <p class="www_code">$ sh snapshot/debian/orig-tar.sh</p>
      <p>which will retrieve the latest version for each LLVM subproject
        (llvm, clang, lldb, etc.) from the main development SVN and repack
        it as a set of tarballs.</p></li>
    <li><p>Unpack the original tarballs and apply quilt Debian patches.</p>
      <p>run the unpack.sh script,</p>
      <p class="www_code">$ sh snapshot/debian/unpack.sh</p>
      <p>which will unpack the source tree inside a new directory such as
        <i>branches/llvm-toolchain-snapshot_3.9~svn268942</i>.
        Depending on the current snapshot version number and svn release,
        the directory name will be different. Quilt patches will then be
        applied.</p></li>
    <li><p>Build the binary packages using,</p>
      <p class="www_code">$ fakeroot debian/rules binary</p>
      <p>When debugging, successive builds can be recompiled faster by using tools
        such as ccache (PATH=/usr/lib/ccache:$PATH fakeroot debian/rules
        binary).</p></li>
  </ol>

  <h2>Retrieving a specific branch or release candidate with orig-tar.sh</h2>

  <p>When using orig-tar.sh, if you need to retrieve a specific branch, you can
    pass the branch name as the first argument. For example, to get the 3.8 release
    branch at
    <i>http://llvm.org/svn/llvm-project/{llvm,...}/branches/release_38</i> you
    should use,</p>
  <p class="www_code">$ sh 3.8/debian/orig-tar.sh release_38</p>
  <p>To retrieve a specific release candidate, you can pass the branch name as the
    first argument, and the tag rc number as the second argument. For example, to
    get the 3.8.0 release candidate rc3 at
    <i>http://llvm.org/svn/llvm-project/{llvm,...}/tags/RELEASE_380/rc3</i>
    you should use,</p>

  <p class="www_code">$ sh 3.8/debian/orig-tar.sh RELEASE_380 rc3</p>

  <h2>Organization of the repository</h2>
  <p>The Debian package for each LLVM point release is maintained as a separate
    SVN branch in the branches/ directory. For example, the 3.8 release lives at
    branches/3.8.</p>
  <p>The current snapshot release is maintained at branches/snapshot.</p>

  <h2>Additional maintainer scripts</h2>
  <p>The script <i>qualify-clang.sh</i> that is found at the SVN root should
    be used to quickly test a newly built clang package. It runs a short set
    of sanity-check tests.</p>
  <p>The script <i>releases/snapshot/debian/prepare-new-release.sh</i> is used when
    preparing a new point release. It automatically replaces version numbers in
    various files of the package.</p>
</div>

<!--
Changes:

- May 25th 2016:
  * Initial version
-->
<p style="font-size: smaller;">
     Contact: <a href="mailto:sylvestre@debian.org">Sylvestre Ledru</a>
<br />Build infra by <a href="http://www.irill.org/">IRILL</a> / Hosting by LLVM Foundation
</p>

</div> <!-- rel_container -->

</body>
</html>

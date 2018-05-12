This page stores the various jenkins job configuration and helpers to build:
http://llvm-jenkins.debian.net/

This is the configuration for the master node.

Two other repositories are used to configure the blades:
* The PXE & preseed configuration to install the OS of the nodes https://github.com/opencollab/llvm-slave-pxe
* The salt configuration to install and configure all slaves https://github.com/opencollab/llvm-slave-salt

Currently, the master is hosted on ursae.siege.inria.fr
The blades are on a PowerEdge Blade Servers on a private LAN and some other servers.


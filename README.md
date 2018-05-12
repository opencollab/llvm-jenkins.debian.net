This page stores the various jenkins job configuration and helpers to build:
http://llvm-jenkins.debian.net/

This is the configuration for the master node.

Two other repositories are used to configure the blades:
* The PXE & preseed configuration to install the OS of the nodes https://github.com/opencollab/llvm-slave-pxe
* The salt configuration to install and configure all slaves https://github.com/opencollab/llvm-slave-salt

Currently, the master is hosted on ursae.siege.inria.fr
The blades are on a PowerEdge Blade Servers on a private LAN and some other servers.

## How to add a new blade

For example, let's say that I want to configure a new blade, I will do the following:

1) Add the node here: https://github.com/opencollab/llvm-slave-salt/blob/master/llvm-slave-jenkins/secret.lst
(the ip are already configured in the PXE in https://github.com/opencollab/llvm-slave-pxe/blob/master/dnsmasq.conf and https://github.com/opencollab/llvm-slave-pxe/blob/master/iplist )

2) go in the platform blade interface. change the boot mode of the blade for PXE and reboot it.

3) the blade will reboot on pxe mode, get a dhcp ip and then start the install process
https://github.com/opencollab/llvm-slave-pxe/blob/master/preseed.cfg
Wait for a while

4) on the master node, accept the key with *salt-key -A <name>*

5) Then, still on the master node, *salt -v '<name>' state.highstate*
to install everything

6) On the blade, start the jenkins node with */home/jenkins/run-slave.sh*

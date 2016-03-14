---
layout: post
title: "Set up three-node Vertica sandbox VMs on Mac"
date: 2016-03-12 14:35:19 -0800
comments: true
published: true
categories: 
- Vertica
- CentOS
- VMWare
- MacOSX
---

I have been using a **single-node** Vertica VM to run ETL tests for [sometime](/blog/2016/01/10/find-and-replace-a-string-in-multiple-files/).
The only minor problem is when we add `KSAFE 1` in our DDL scripts (i.e., `CREATE TABLE` statements) for production purposes which gives error on single-node VM when running DDL scripts to set up schema.
Even then, the workaround for running those DDL scripts in tests is easy enough, as shown in the [previous blog post](/blog/2016/01/10/find-and-replace-a-string-in-multiple-files/).

In this blog post, I looked into setting up a Vertica cluster of **three** VM nodes on Mac, so that my Vertica sandbox is similar to production system, and I can run DDL scripts directly for test setup without modifications. 
Three-node cluster is fortunately also the limit of the free Vertica Community Edition.
This blog post documents some of my mistakes, going down the wrong paths, while trying to do so.

### Using Vertica VM from HPE support?

If you already downloaded Vertica VM from HP website, you might consider cloning that VM and configuring the clones to make a three-node VM cluster of Vertica.
Here are the basic steps of cloning VM on Mac OSX using VMWare Fusion if you are interested in going in that direction: 

1. Download Vertica VM from [HPE support website](https://my.vertica.com/download/vertica/community-edition/).
1. Start up the Vertica VM in VMWare Fusion. Make sure the VM can connect to Internet. 
   1. Username: dbadmin. Password: password. Root password: password. From [here](https://my.vertica.com/docs/7.1.x/HTML/Content/Authoring/GettingStartedGuide/DownloadingAndStartingVM/DownloadingAndStartingVM.htm).
1. Change the hostname to a shorter name.
1. Turn off the VM.
1. Clone in VMWare Fusion using "Full Clone" option.
1. Start up 3 machines.
1. Change the hostname of the two clones into something different: e.g., vertica72b and vertica72c.
1. Make sure all 3 nodes can be connected to Internet, having some IP address. Obtain the IP addresses for each node (ip addr).

Depending on the version of VM that you download, you might be hit with the following problem:

* Vertica is already installed on that Vertica VM as a single-host cluster. You cannot expand the cluster to three VM nodes without uninstalling and reinstalling Vertica. 

``` plain Error message when trying to expand
[dbadmin@vertica ~]$ sudo /opt/vertica/sbin/update_vertica -A 192.168.5.174
Vertica Analytic Database 7.1.1-0 Installation Tool


>> Validating options...


Mapping hostnames in --add-hosts (-A) to addresses...
Error: Existing single-node localhost (loopback) cluster cannot be expanded
Hint: Move cluster to external address first. See online documentation.
Installation FAILED with errors.

Installation stopped before any changes were made.
```

The offical explaination from HP Vertica's documentation (quoted from [here](https://my.vertica.com/docs/7.2.x/HTML/Content/Authoring/AdministratorsGuide/ManageNodes/AddingNodes.htm)):

{% blockquote %}
If you installed Vertica on a single node without specifying the IP address or hostname (or you used localhost), you cannot expand the cluster. You must reinstall Vertica and specify an IP address or hostname that is not localhost/127.0.0.1.
{% endblockquote %}

This problem seems insurmountable to me unless you are a good Linux hacker and/or willing to do a fresh reinstallation of Vertica on that VM.

### Installing Vertica Community Edition on a fresh VM

In this approach, I have to install Vertica (free Community Edition) from scratch on a fresh Linux VM. 
Then, I clone that VM and configure the clones to make a three-node cluster of Vertica.

#### Before installing Vertica

Download CentOS VM from [osboxes.org](http://www.osboxes.org/). I used CentOS 6 VM. 
Note that CentOS 5 or older is no longer supported by Vertica VM (see last section below) and CentOS 7 VM from that website is not stable in my experience (2016 Feb).
The following information may be useful when you prepare that CentOS VM before installing Vertica on it:

``` plain
Username: osboxes
Password: osboxes.org
Root password: osboxes.org
```

Note that Network connection may not work for that CentOS box. To make it work, I added the following line to the end of my `.vmx` file based on this [link](https://www.centos.org/forums/viewtopic.php?f=47&t=47724):

``` plain
ethernet0.virtualDev = "e1000"
```

Install and configure SSH on the CentOS VM, as detailed in [here](http://www.cyberciti.biz/faq/centos-ssh/).

#### Installing Vertica

Follow the steps in this [link](http://vertica.tips/2015/10/29/installing-3-node-vertica-7-2-sandbox-environment-using-windows-and-virtualbox/view-all/) to set up a three-node Vertica VMs.
Although the instruction is for VMs in VirtualBox on Windows, similar steps apply for VMWare Fusion on Mac OSX.
Note that in VMWare Fusion, clone the VM using the option "Create Full Clone" (instead of "Create Linked Clone").
In addition, to keep it consistent with single-node Vertica VM from HPE support website, you might want to create a new database user with username `dbadmin` and `password` as password.
It will help when you need to switch back and forth from using three-node Vertica VM to single-node VM for unit testing purposes.

#### After installing Vertica

After Vertica installation and cluster rebooting, you might encounter one or more problems with the following error messages:

``` plain Common issues after rebooting
### Issue 1
Network Connection is not available.

### Issue 2
FAIL (S0150): https://my.vertica.com/docs/7.1.x/HTML/index.htm#cshid=S0150
These disks do not have ‘deadline’ or ‘noop’ IO scheduling: ‘/dev/sda1′

### Issue 3
FAIL (S0310): https://my.vertica.com/docs/7.1.x/HTML/index.htm#cshid=S0310
Transparent hugepages is set to ‘always’. Must be ‘never’ or ‘madvise’.
```

To resolve the above issues, use the following commands as superuser, in that order:

``` plain Use the following commands as superuser
dhclient
echo deadline > /sys/block/sda/queue/scheduler
echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled
```

Those issues are the most common issues that I frequently encountered. For other issues and troubleshooting tips, check "Troubleshooting" section below.
Remember to shutdown Vertica database before rebooting one or more nodes in the VM cluster.

After making sure Vertica is running on the three VMs, follow the steps from [here](https://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/GettingStartedGuide/InstallingAndConnectingToVMart/QuickInstallation.htm) to create a Vertica database.
Simply create a new empty schema in that database for unit testing purpose.
You now can connect to that Vertica database using some Vertica client (e.g., vsql, SQuirreL) and the following connection information:

``` plain Vertica connection
jdbc:vertica://[your_VM_IP_address]:5433/VMart

Username: dbadmin
Password: password
```

### Troubleshooting tips

In this section, I will list some problems that I encountered when installing and using the three-node VM cluster of Vertica and how to work around those.
Each installation problem has a documentation page that is displayed in the error message, such as [this page](https://my.vertica.com/docs/7.1.x/HTML/index.htm#cshid=S0150) for S0150 error.
I listed the quick, single-command solutions here for reference purpose.
However, there is no guarantee that such solutions will work in all contexts and it is recommended to read the documentation page to understand what went wrong.

<!-- 
#### S0180 "insufficient swap size"

1. https://www.digitalocean.com/community/tutorials/how-to-add-swap-on-centos-7

``` plain Adding swap fails
[root@vertica72 osboxes]# swapoff /dev/sda2
[root@vertica72 osboxes]# swapon -s
[root@vertica72 osboxes]# swapon /swapfile
swapon: /swapfile: swapon failed: Invalid argument
```

This is due to a bug

1. http://superuser.com/questions/539287/swapon-failed-invalid-argument-on-a-linux-system-with-btrfs-filesystem


1. https://www.centos.org/docs/5/html/Deployment_Guide-en-US/s1-swap-adding.html
-->

#### S0081: SELinux appears to be enabled and not in permissive mode

``` plain
FAIL (S0081): https://my.vertica.com/docs/7.1.x/HTML/index.htm#cshid=S0081
SELinux appears to be enabled and not in permissive mode.
```

As mentioned in the HP Vertica documentation page, for CentOS 6, add the following line into file `/etc/sysconfig/selinux` as root/sudo:

``` plain 
setenforce 0
```

#### S0150: These disks do not have ‘deadline’ or ‘noop’ IO scheduling

``` plain Error message
FAIL (S0150): https://my.vertica.com/docs/7.1.x/HTML/index.htm#cshid=S0150
These disks do not have ‘deadline’ or ‘noop’ IO scheduling: ‘/dev/sda1′
```

To fix this problem in CentOS 6, run this command as root/sudo:

``` plain Run this command
echo deadline > /sys/block/sda/queue/scheduler
```

#### S0310: Transparent hugepages is set to ‘always’. Must be ‘never’ or ‘madvise’.

``` plain Error message
FAIL (S0310): https://my.vertica.com/docs/7.1.x/HTML/index.htm#cshid=S0310
Transparent hugepages is set to ‘always’. Must be ‘never’ or ‘madvise’.
```

To fix this problem in CentOS 6, run this command as root/sudo:

``` plain Run this command
echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled
```

#### ETL fails with "ERROR 3587:  Insufficient resources to execute plan"

After the three-node VM cluster is up and running, you might get the following error when trying to run some complex ETL script:

``` plain Error message
vsql:repo_home/sql/my_etl.sql:1091: ERROR 3587:  Insufficient resources to execute plan on pool general [Request Too Large:Memory(KB) Exceeded: Requested = 3541705, Free = 2962279 (Limit = 2970471, Used = 8192)]
```

[Vertica recommends](https://community.dev.hpe.com/t5/Vertica-Forum/ERROR-ERROR-3587-Insufficient-resources-to-execute-plan-on-pool/td-p/233226) a minimum of 4GB of memory per processor core.
The comprehensive list of hardware requirements for Vertica can be found [here](https://my.vertica.com/docs/Hardware/HP_Vertica%20Planning%20Hardware%20Guide.pdf).
Note that, it is also recommended all nodes in the cluster have similar processor and memory provisions. 
In other words, a node with 2 GB memory mixed with another with 4 GB is NOT recommmended.
In this case, each of my VMs had two processor cores with only 4 GB in memory. 
I had to reconfigure the VMs to one processor core with 6 GB in memory each to get that particular ETL script working.

### Using older CentOS for Vertica VM (CentOS 5)

Installing latest version of Vertica on **CentOS 5** is NOT easy, if not impossible. CentOS 5 is offically dropped from support by HP Vertica.

I tried to reinstall Vertica after encountering the error "Existing single-node localhost (loopback) cluster cannot be expanded" as mentioned above. 
Then, you might encounter this error when trying to install the latest version of Vertica:

``` plain Vertica installation error in CentOS 5
ERROR with rpm_check_debug vs depsolve:
rpmlib(FileDigests) is needed by vertica-7.2.1-0.x86_64
rpmlib(PayloadIsXz) is needed by vertica-7.2.1-0.x86_64
Complete!
```

Running `sudo yum -y update rpm` does not work. 
The reason is that CentOS 5 and CentOS 6 have very different versions of `rpm` and `rpmlib`. 
The CentOS 6 version has support for newer payload compression and a newer `FileDigests` version than the version of `rpm` on CentOS 5 can support.
Since CentOS 5 is dropped from support by HP Vertica, we can expect this error won't be resolved any time soon.

I would recommend using CentOS 6 when trying to install Vertica from scratch, with instructions shown in section above.
The choice of using CentOS 5 to begin with is totally a personal choice: I have a very stable CentOS 5 VM with lots of utility applicaitons installed.

### Links

1. [Three-node VM setup in VirtualBox](http://vertica.tips/2015/10/29/installing-3-node-vertica-7-2-sandbox-environment-using-windows-and-virtualbox/view-all/)
1. [CentOS SSH Installation And Configuration](http://www.cyberciti.biz/faq/centos-ssh/)

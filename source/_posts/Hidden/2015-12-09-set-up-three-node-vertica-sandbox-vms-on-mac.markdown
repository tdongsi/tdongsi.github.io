---
layout: post
title: "Set up three-node Vertica VM sandbox"
date: 2016-03-12 14:35:19 -0800
comments: true
published: false
categories: 
- Vertica
- CentOS
- MacOSX
---

I have been using a **single-node** Vertica VM to run ETL tests for [sometime](/blog/2016/01/10/find-and-replace-a-string-in-multiple-files/).
The only minor problem is that when we add `KSAFE 1` in our DDL scripts (i.e., `CREATE TABLE` statements) for production purposes, it gives error on single-node VM when running DDL scripts to set up schema since single-node cluster is not k-safe.
Even then, the workaround for running those DDL scripts in tests is easy enough, as shown in the [previous blog post](/blog/2016/01/10/find-and-replace-a-string-in-multiple-files/).

In this blog post, I looked into setting up a Vertica cluster of **three** VM nodes on Mac, so that my Vertica sandbox is similar to production system, and I can run DDL scripts directly for test setup without modifications. 
Three-node cluster is fortunately also the limit of the free Vertica Community Edition.
This blog post documents some of my mistakes and wrong approaches while trying to do so.

### Using Vertica VM from HPE support?

If you already downloaded Vertica VM from HP website, you might consider cloning that VM and configuring the clones to make a three-node VM cluster of Vertica.
Here are the basic steps of cloning VM on Mac OSX using VMWare Fusion if you are interested in that direction: 

1. Download Vertica VM from [HPE support website](https://my.vertica.com/download/vertica/community-edition/).
1. Start up the Vertica VM in VMWare Fusion. Make sure the VM can connect to Internet. 
   1. Username: dbadmin. Password: password. Root password: password. From [here](https://my.vertica.com/docs/7.1.x/HTML/Content/Authoring/GettingStartedGuide/DownloadingAndStartingVM/DownloadingAndStartingVM.htm).
1. Change the hostname to a shorter name.
1. Turn off the VM.
1. Clone in VMWare Fusion using "Create Full Clone" option (NOT "Create Linked Clone").
1. Start up the three virtual machines.
1. Change the hostname of the two new clones into something different: e.g., vertica72b and vertica72c.
1. Make sure all 3 nodes can be connected to Internet, having some IP address. Obtain the IP addresses for each node (`ip addr` command).

Depending on the version of VM that you downloaded, you might be hit with the following problem:

* Vertica is already installed on that VM as a single-host cluster. You cannot expand the cluster to three VM nodes (without uninstalling and reinstalling Vertica). 

You will get the following error message when trying to use Vertica tools to expand the cluster:

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

The official explanation from HP Vertica's documentation (quoted from [here](https://my.vertica.com/docs/7.2.x/HTML/Content/Authoring/AdministratorsGuide/ManageNodes/AddingNodes.htm)):

{% blockquote %}
If you installed Vertica on a single node without specifying the IP address or hostname (or you used localhost), you cannot expand the cluster. You must reinstall Vertica and specify an IP address or hostname that is not localhost/127.0.0.1.
{% endblockquote %}

This problem seems insurmountable to me unless you are a Linux hacker and/or willing to do a fresh reinstallation of Vertica on that VM.

### Installing Vertica Community Edition on a fresh VM

In this approach, I have to install Vertica (free Community Edition) from scratch on a fresh Linux VM. 
Then, I clone that VM and configure the clones to make a three-node cluster of Vertica.

#### Before installing Vertica

Download CentOS VM from [osboxes.org](http://www.osboxes.org/). I used CentOS 6 VM. 
Note that CentOS 5 or older is no longer supported by Vertica HP (check out my attempt in the last section below) and CentOS 7 VM from that website is not stable in my experience (2016 Feb).
The following information may be useful when you prepare that CentOS VM before installing Vertica on it:

``` plain
Username: osboxes
Password: osboxes.org
Root password: osboxes.org
```

Note that Wired Network connection may not work for that CentOS box. 
To make it work, I added the following line to the end of my `.vmx` file based on this [link](https://www.centos.org/forums/viewtopic.php?f=47&t=47724):

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

Those issues are the most common issues that I frequently encountered. For other issues, more discussions and troubleshooting tips, check [this "Troubleshooting" post](/blog/2016/03/13/vertica-10-installation-troubleshooting-tips/).
Remember to shutdown Vertica database before rebooting one or more nodes in the VM cluster.

After making sure Vertica is running on the three VMs, follow the steps from [here](https://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/GettingStartedGuide/InstallingAndConnectingToVMart/QuickInstallation.htm) to create a Vertica database.
Simply create a new empty schema in that VMart database for unit testing purpose.
You now can connect to that Vertica database using some Vertica client (e.g., vsql, SQuirreL) and the following connection information:

``` plain Vertica connection
jdbc:vertica://[your_VM_IP_address]:5433/VMart

Username: dbadmin
Password: password
```

### Using older CentOS for Vertica VM (CentOS 5)

Installing latest version of Vertica on **CentOS 5** is NOT easy, if not impossible. CentOS 5 is officially dropped from support by HP Vertica.

I tried to reinstall Vertica after encountering the error "Existing single-node localhost (loopback) cluster cannot be expanded" as mentioned above. 
Then, I encountered this error when trying to install the latest version of Vertica (7.2):

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
The choice of using CentOS 5 to begin with is totally a personal choice: I have a very stable CentOS 5 VM with lots of utility applications installed.
There is no apparent advantage of using CentOS 5 over CentOS 6.

### Links

1. [Three-node VM setup in VirtualBox](http://vertica.tips/2015/10/29/installing-3-node-vertica-7-2-sandbox-environment-using-windows-and-virtualbox/view-all/)
1. [CentOS SSH Installation And Configuration](http://www.cyberciti.biz/faq/centos-ssh/)


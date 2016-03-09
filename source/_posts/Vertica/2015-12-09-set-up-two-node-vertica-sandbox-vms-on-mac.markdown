---
layout: post
title: "Set up three-node Vertica sandbox VMs on Mac"
date: 2016-1-29 14:35:19 -0800
comments: true
published: false
categories: 
- Vertica
- CentOS
---

I have been using a **single-node** Vertica VM to run ETL tests for [sometime](/blog/2016/01/10/find-and-replace-a-string-in-multiple-files/).
The only minor problem is when we add `KSAFE 1` in our DDL scripts (i.e., `CREATE TABLE` statements) for production purposes which gives error on single-node VM when running DDL scripts to set up schema.
Even then, the workaround for running those DDL scripts in tests is easy enough, as shown in the [previous blog post](/blog/2016/01/10/find-and-replace-a-string-in-multiple-files/).

In this blog post, I looked into setting up a Vertica cluster of **three** VM nodes on Mac, so that my Vertica sandbox is similar to production system, and I can run DDL scripts directly for test setup without modifications. 
Three-node cluster is fortunately also the limit of the free Vertica Community Edition.

### Using Vertica VM from HPE support

1. Download Vertica VM from [HPE support website](https://my.vertica.com/download/vertica/community-edition/).
1. Start up the Vertica VM in VMWare Fusion. Make sure the VM can connect to Internet. 
   1. Username: dbadmin. Password: password. Root password: password. From [here](https://my.vertica.com/docs/7.1.x/HTML/Content/Authoring/GettingStartedGuide/DownloadingAndStartingVM/DownloadingAndStartingVM.htm)
1. Change the hostname to the shorter name
1. Turn off
1. Clone in VMWare Fusion. Full Clone.
1. Start up 3 machines.
1. Change the hostname of the two clones into something different: e.g., vertica72b and vertica72c.
1. Make sure all 3 nodes can be connected to Internet, having some IP address.
1. Obtain the IP addresses for each node (ip addr).



## Installing new Vertica

Download CentOS box from [osboxes.org](http://www.osboxes.org/). I used CentOS 6.

Make Network connection work for that CentOS box based on this [link](https://www.centos.org/forums/viewtopic.php?f=47&t=47724). I added the following line to the end of my .vmx file:

```
ethernet0.virtualDev = "e1000"
```

1. http://vertica.tips/2015/10/29/installing-3-node-vertica-7-2-sandbox-environment-using-windows-and-virtualbox/view-all/
1. http://www.cyberciti.biz/faq/centos-ssh/

### Troubleshooting

#### S0180 "insufficient swap size"

1. https://www.digitalocean.com/community/tutorials/how-to-add-swap-on-centos-7

```
[root@vertica72 osboxes]# swapoff /dev/sda2
[root@vertica72 osboxes]# swapon -s
[root@vertica72 osboxes]# swapon /swapfile
swapon: /swapfile: swapon failed: Invalid argument
```

This is due to a bug

1. http://superuser.com/questions/539287/swapon-failed-invalid-argument-on-a-linux-system-with-btrfs-filesystem


1. https://www.centos.org/docs/5/html/Deployment_Guide-en-US/s1-swap-adding.html

#### S0081 "SELinux appears to be enabled and not in permissive mode"

```
FAIL (S0081): https://my.vertica.com/docs/7.1.x/HTML/index.htm#cshid=S0081
SELinux appears to be enabled and not in permissive mode.
```

1. http://geeks-cache.comoj.com/?p=560



1. https://my.vertica.com/docs/7.1.x/HTML/Content/Authoring/GettingStartedGuide/InstallingAndConnectingToVMart/QuickInstallation.htm

### Possibility of using older Vertica VM (CentOS 5)

If you are like me and already downloaded the previous version of Vertica VM from HP website, you might consider cloning that VM and setting the clones using the steps above.

Before going that route, here is some caution from my personal painful experience.

* Vertica is already installed on that VM as a single-host cluster. You cannot expand the cluster to three VM nodes without uninstalling and reinstalling Vertica. 

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

The offical explaination from HP Vertica's documentation.

{% blockquote %}
If you installed Vertica on a single node without specifying the IP address or hostname (or you used localhost), you cannot expand the cluster. You must reinstall Vertica and specify an IP address or hostname that is not localhost/127.0.0.1.
{% endblockquote %}

* Reinstalling latest version of Vertica on **CentOS 5** is NOT easy. CentOS 5 is offically dropped from support by HP Vertica.

You are forced to reinstall Vertica after encountering the error above. Then, you might encounter this error when trying to install the latest version of Vertica:

```
ERROR with rpm_check_debug vs depsolve:
rpmlib(FileDigests) is needed by vertica-7.2.1-0.x86_64
rpmlib(PayloadIsXz) is needed by vertica-7.2.1-0.x86_64
Complete!
```

Running `sudo yum -y update rpm` does not work. CentOS 5 and CentOS 6 have wildly different versions of rpm (and rpmlib) and the CentOS 6 version has support for newer payload compression and a newer FileDigests version than the version of rpm (and rpmlib) on CentOS 5 can support.

Since CentOS 5 is dropped from support by HP Vertica, you can expect this won't be resolved any time soon.

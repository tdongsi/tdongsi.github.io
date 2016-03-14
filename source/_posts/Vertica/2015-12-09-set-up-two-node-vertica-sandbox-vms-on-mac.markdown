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
   1. Username: dbadmin. Password: password. Root password: password. From [here](https://my.vertica.com/docs/7.1.x/HTML/Content/Authoring/GettingStartedGuide/DownloadingAndStartingVM/DownloadingAndStartingVM.htm)
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

The offical explaination from HP Vertica's documentation. TODO: Citation

{% blockquote %}
If you installed Vertica on a single node without specifying the IP address or hostname (or you used localhost), you cannot expand the cluster. You must reinstall Vertica and specify an IP address or hostname that is not localhost/127.0.0.1.
{% endblockquote %}

The problem seems insurmountable to me unless you are a good Linux hacker and/or willing to do a fresh reinstallation of Vertica on that VM.

### Installing Vertica Community Edition on a fresh VM

Download CentOS box from [osboxes.org](http://www.osboxes.org/). I used CentOS 6 VM. 
Note that CentOS 5 or older is no longer supported by Vertica VM (see last section below) and CentOS 7 VM is not stable in my experience (2016 Feb).

Make Network connection work for that CentOS box based on this [link](https://www.centos.org/forums/viewtopic.php?f=47&t=47724). I added the following line to the end of my .vmx file:

```
ethernet0.virtualDev = "e1000"
```

1. http://vertica.tips/2015/10/29/installing-3-node-vertica-7-2-sandbox-environment-using-windows-and-virtualbox/view-all/
1. http://www.cyberciti.biz/faq/centos-ssh/


### Troubleshooting

#### ETL fails

```
vsql:repo_home/qbo/sql/qbo_company_etl.sql:1091: ERROR 3587:  Insufficient resources to execute plan on pool general [Request Too Large:Memory(KB) Exceeded: Requested = 3541705, Free = 2962279 (Limit = 2970471, Used = 8192)]
```

1. https://my.vertica.com/docs/Hardware/HP_Vertica%20Planning%20Hardware%20Guide.pdf
1. https://community.dev.hpe.com/t5/Vertica-Forum/ERROR-ERROR-3587-Insufficient-resources-to-execute-plan-on-pool/td-p/233226

Vertica recommends a minimum of 4GB of memory per core. i see that you have 2 cores and just 1 GB of memory. Memory allocation is very low. You need to have 2*4B = 8GB of memory. 


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
The reason is that CentOS 5 and CentOS 6 have very different versions of `rpm` (and `rpmlib`). 
The CentOS 6 version has support for newer payload compression and a newer FileDigests version than the version of rpm on CentOS 5 can support.
Since CentOS 5 is dropped from support by HP Vertica, you can expect this error won't be resolved any time soon.

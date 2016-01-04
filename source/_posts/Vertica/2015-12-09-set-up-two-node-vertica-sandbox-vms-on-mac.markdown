---
layout: post
title: "Set up three-node Vertica sandbox VMs on Mac"
date: 2015-12-09 14:35:19 -0800
comments: true
published: false
categories: 
- Vertica
---

## Vertica VM as sandbox test environment

It is definitely better if you can have separate schema for each developer in Pre-Prod, please go for it first. BUT if it is NOT possible, I recommend that we look into using Vertica Virtual Machine (VM) for sandbox test environment, as a cheap alternative.

In QE testing, some of our tests add mock records to represent corner cases or run ETLs multiple times to simulate daily incremental updates. I can not use SBG_DWH_QE schema for these which is shared by all QEs for that since it might affect/destroy valuable source data as well Jenkins run, i.e., "stepping on each other's toes” like you said. My solution is to use Vertica VM as sandbox test environment for those tests. 

## Single-node VM versus three-node VM cluster

I have been using a single-node Vertica VM to run tests for a while. And it works wonderfully for testing purpose, especially when you want to isolate issues, e.g., a corner case. The only minor problem is when we add "KSAFE 1" in our DDLs which gives error (for single-node) when running DDLs to set up schema. Even then, the workaround for running tests is easy enough in sbg-ecosystem repo since all DDLs are in "table" folder.

As we move to sbg_datasets repo, the work around for the problem "KSAFE 1” for single-node VM is probably messy. I already looked into setting up a Vertica cluster of two VM nodes and it seems "doable", at least on Mac (“doable” means "not very smooth first time, but repeatable” :) ). If we cannot request individual schema on Pre-Prod, I can document it and share on how I set up a cluster of Vertica VMs.


To work around "KSAFE 1" error.

Database with 1 or 2 hosts cannot be k-safe and it may lose data if it crashes.

## Installing new Vertica

Download CentOS box from oxboxes.org. I used CentOS 6.

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

## Troubleshooting with older Vertica VM

Download the Vertica VM from HP website.

In VMWare Fusion, create clone.


```
[dbadmin@vertica ~]$ /sbin/ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:0c:29:2d:60:e7 brd ff:ff:ff:ff:ff:ff
    inet 192.168.5.133/24 brd 192.168.5.255 scope global eth0
    inet6 fe80::20c:29ff:fe2d:60e7/64 scope link 
       valid_lft forever preferred_lft forever
```

```
[dbadmin@vertica ~]$ /sbin/ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 1000
    link/ether 00:0c:29:a6:98:5d brd ff:ff:ff:ff:ff:ff
    inet 192.168.5.174/24 brd 192.168.5.255 scope global eth0
    inet6 fe80::20c:29ff:fea6:985d/64 scope link 
       valid_lft forever preferred_lft forever
```


```
[dbadmin@vertica ~]$ sudo /opt/vertica/sbin/update_vertica -A 192.168.5.174
Vertica Analytic Database 7.1.1-0 Installation Tool


>> Validating options...


Mapping hostnames in --add-hosts (-A) to addresses...
Error: Existing single-node localhost (loopback) cluster cannot be expanded
Hint: Move cluster to external address first. See online documentation.
Installation FAILED with errors.

Installation stopped before any changes were made.
```

```
If you installed Vertica on a single node without specifying the IP address or hostname (or you used localhost), you cannot expand the cluster. You must reinstall Vertica and specify an IP address or hostname that is not localhost/127.0.0.1.
```


Uninstall vertica
```
[dbadmin@vertica myFile]$ rpm -e vertica-7.1.1-0
error: can't create transaction lock on /var/lib/rpm/__db.000
[dbadmin@vertica myFile]$ sudo !!
sudo rpm -e vertica-7.1.1-0
Shutting down vertica agent daemon
Stopping vertica agent: vertica agent is already running, stopping...

Deleting vertica autorestart support
Deleting vertica agent support
```


```
ERROR with rpm_check_debug vs depsolve:
rpmlib(FileDigests) is needed by vertica-7.2.1-0.x86_64
rpmlib(PayloadIsXz) is needed by vertica-7.2.1-0.x86_64
Complete!
```

`sudo yum -y update rpm`

CentOS 5 and CentOS 6 have wildly different versions of rpm (and rpmlib) and the CentOS 6 version has support for newer payload compression and a newer FileDigests version than the version of rpm (and rpmlib) on CentOS 5 can support.

`rpm -Uvh pathname`
---
layout: post
title: "Set up two-node Vertica sandbox VMs on Mac"
date: 2015-12-09 14:35:19 -0800
comments: true
published: false
categories: 
- Vertica
---

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
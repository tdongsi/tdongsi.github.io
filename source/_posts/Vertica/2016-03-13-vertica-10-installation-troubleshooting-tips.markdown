---
layout: post
title: "Vertica installation: Troubleshooting tips"
date: 2016-03-13 22:24:23 -0700
comments: true
categories: 
- Vertica
- CentOS
---

In this post, I will list some problems that I encountered when installing and using the [three-node VM cluster of Vertica](/blog/2016/03/12/set-up-three-node-vertica-sandbox-vms-on-mac/) and how to work around those.
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

### S0081: SELinux appears to be enabled and not in permissive mode

``` plain
FAIL (S0081): https://my.vertica.com/docs/7.1.x/HTML/index.htm#cshid=S0081
SELinux appears to be enabled and not in permissive mode.
```

As mentioned in the HP Vertica documentation page, for CentOS 6, add the following line into file `/etc/sysconfig/selinux` as root/sudo:

``` plain 
setenforce 0
```

### S0150: These disks do not have ‘deadline’ or ‘noop’ IO scheduling

``` plain Error message
FAIL (S0150): https://my.vertica.com/docs/7.1.x/HTML/index.htm#cshid=S0150
These disks do not have ‘deadline’ or ‘noop’ IO scheduling: ‘/dev/sda1′
```

To fix this problem in CentOS 6, run this command as root/sudo:

``` plain Fix until next reboot
echo deadline > /sys/block/sda/queue/scheduler
```

Changes to scheduler only last until the system is rebooted, so you need to add the above command to a startup script (such as `/etc/rc.local`) like in this command.

``` plain Permanent fix
echo 'echo deadline > /sys/block/sda/queue/scheduler' >> /etc/rc.local
```

### S0310: Transparent hugepages is set to ‘always’. Must be ‘never’ or ‘madvise’.

``` plain Error message
FAIL (S0310): https://my.vertica.com/docs/7.1.x/HTML/index.htm#cshid=S0310
Transparent hugepages is set to ‘always’. Must be ‘never’ or ‘madvise’.
```

To fix this problem in CentOS 6, run this command as root/sudo:

``` plain Fix until next reboot
echo never > /sys/kernel/mm/redhat_transparent_hugepage/enabled
```

The permanent fix is also available in the [documentation page](https://my.vertica.com/docs/7.1.x/HTML/index.htm#cshid=S0310) in the error message above.

### S0020: Readahead size of sda (/dev/sda1,/dev/sda2) is too low for typical systems

``` plain Error message
FAIL (S0020): https://my.vertica.com/docs/7.1.x/HTML/index.htm#cshid=S0020
Readahead size of sda (/dev/sda1,/dev/sda2) is too low for typical systems: 256 < 2048
```
To fix this problem in CentOS 6, run this command as root/sudo:

``` plain Run this command
/sbin/blockdev –setra 2048 /dev/sda
```

### ETL fails with "ERROR 3587:  Insufficient resources to execute plan"

After the three-node VM cluster is up and running, you might get the following error when trying to run some complex ETL script:

``` plain Error message
vsql:repo_home/sql/my_etl.sql:1091: ERROR 3587:  Insufficient resources to execute plan on pool general 
[Request Too Large:Memory(KB) Exceeded: Requested = 3541705, Free = 2962279 (Limit = 2970471, Used = 8192)]
```

[Vertica recommends](https://community.dev.hpe.com/t5/Vertica-Forum/ERROR-ERROR-3587-Insufficient-resources-to-execute-plan-on-pool/td-p/233226) a minimum of 4GB of memory per processor core.
The comprehensive list of hardware requirements for Vertica can be found [here](https://my.vertica.com/docs/Hardware/HP_Vertica%20Planning%20Hardware%20Guide.pdf).
Note that, it is also recommended all nodes in the cluster have similar processor and memory provisions. 
In other words, a node with 2 GB memory mixed with another with 4 GB is NOT recommended.
In this case, each of my VMs had two processor cores with only 4 GB in memory. 
I had to reconfigure the VMs to one processor core with 6 GB in memory each to get that particular ETL script working.

### Links

1. Documentation pages for errors: e.g., [S0150](https://my.vertica.com/docs/7.1.x/HTML/index.htm#cshid=S0150).
   * Read pages like this to figure out fixes for problems encountered during Vertica installation.
1. [Hardware Requirements for Vertica](https://my.vertica.com/docs/Hardware/HP_Vertica%20Planning%20Hardware%20Guide.pdf)
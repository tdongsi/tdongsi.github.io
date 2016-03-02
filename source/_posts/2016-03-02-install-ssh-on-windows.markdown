---
layout: post
title: "Set up public-key SSH on Windows"
date: 2015-03-22 10:57:33 -0800
comments: true
categories: 
- Bash
- Windows
---

Setting up public-key SSH on Windows is much more tricky than Linux (see [here](/blog/2015/03/02/install-ssh-on-linux/)).

### Install OpenSSH for Windows

Install OpenSSH for Windows to a machine, e.g., `frak16` at the following location `SSH_DIR=C:\space\cuongd\OpenSSH`.
Use OpenSSH installer from [here](http://www.mls-software.com/opensshd.html).
Do NOT use OpenSSH for Windows from SourceForge, which is outdated, even though many top links from Google search "OpenSSH windows" point to it.

Edit the file `etc/passwd` inside `SSH_DIR` defined above. Make sure the home directory for your username, e.g., "/cygdrive/c/space/oqa" for user `oqa`, is in there.

```
oqa:unused_by_nt/2000/xp:13331:10513:oqa,U-OBJY\oqa,S-1-5-21-343818398-1708537768-1417001333-3331:/cygdrive/c/space/oqa:/bin/switch
```

Run the following command for a test run:

```
C:\space\cuongd\OpenSSH>usr\sbin\sshd -d -d -d
```

Use ssh from another host (as client) to test connection. See the client's `ssh_config` below.

```
ssh username@hostname -v

### Example
ssh oqa@frak16 -v
```

After making sure the SSH is installed working properly on `frak16`, run the following in a Command prompt with Admin power to start SSH as a service:

```
net start opensshd
```

Now, you can connect to this Windows machine `frak16` using password authentication.

### Set up public-key SSH


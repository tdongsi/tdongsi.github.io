---
layout: post
title: "Set up public-key SSH on Linux"
date: 2015-03-02 10:57:26 -0800
comments: true
categories:
- Bash
- CentOS
- Ubuntu
---

(1) Log into a Linux system (for CentOS, v5.8 or better) with your user account.

(2) Go to the directory `~/.ssh`. If such directory is not present, create one and set the permissions to 755.

```
mkdir ~/.ssh
chmod 755 ~/.ssh
cd ~/.ssh
```

(3) Generate your private and public keys

```
[frak10-b13]$ ssh-keygen
```

When you get "Enter passphrase (empty for no passphrase):", you can hit enter for a null passphrase for now.
The passphrase can be changed later by using the -p option.
Note that from the `man` page: "USING GOOD, UNGUESSABLE PASSPHRASES IS STRONGLY RECOMMENDED.". 
If `ssh-keygen` returns with "You must specify a key type (-t).", then add the flag "-t rsa".


(4) The ssh-keygen tool stores the private key in `$HOME/.ssh/id_rsa` and the public key in `$HOME/.ssh/id_rsa.pub` in the user’s home directory. 
The user should then copy the contents of `id_rsa.pub` to the `$HOME/.ssh/authorized_keys` file in his home directory on the **remote** machine.
Verify that you have and authorized_keys file in ~/.ssh. If not create one and set the permissions:

```
cat id_rsa.pub >> authorized_keys
chmod 644 ~/.ssh/authorized_keys
```

Verify that you have a known_hosts file `~/.ssh/known_hosts`. 
If not, you can begin to populate this file by doing an ssh session to the system you want to connect to and
answer `yes` to this question:

```
The authenticity of host 'reda64 (172.21.32.38)' can't be established.
RSA key fingerprint is 3f:39:60:a8:b6:c7:37:e6:a6:ff:f5:d2:0b:fc:86:83.
Are you sure you want to continue connecting (yes/no)?
```

### Links

1. [ssh-keygen](https://en.wikipedia.org/wiki/Ssh-keygen)
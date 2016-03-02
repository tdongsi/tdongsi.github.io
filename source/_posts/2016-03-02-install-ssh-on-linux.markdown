---
layout: post
title: "Set up public-key SSH on Linux"
date: 2016-03-02 10:57:26 -0800
comments: true
categories:
- Bash
- CentOS
- Ubuntu
---

How to set up public-key (aka, passwordless) SSH.
1. Log into a CentOS system (Should be CentOS v5.8 or better) with your user account.
2. cd ~/.ssh (if not present then: mkdir ~/.ssh and set the perms to chmod 755)
3. Generate your private and public keys
[frak10-b13]$ ssh-keygen
When you get "Enter same passphrase again:" just hit enter for a null passphrase
If ssh-keygen returns with "You must specify a key type (-t).", then add the flag "-t rsa".

http://socsinfo.cs.mcgill.ca/wiki/Shared_Account_Access
4. verify that you have and authorized_keys file in ~/.ssh
if not create one:
cat id_rsa.pub >> authorized_keys
and set the perms:
chmod 644 ~/.ssh/authorized_keys

5. Verify that you have a known_hosts file
~/.ssh/known_hosts
if not you can begin to populate this file by doing an ssh session to the system you want to connect to and
answer yes to this question:
The authenticity of host 'reda64 (172.21.32.38)' can't be established.
RSA key fingerprint is 3f:39:60:a8:b6:c7:37:e6:a6:ff:f5:d2:0b:fc:86:83.
Are you sure you want to continue connecting (yes/no)?
More information availabl at http://en.wikipedia.org/wiki/Ssh-keygen.
The ssh-keygen tool stores the private key in $HOME/.ssh/id_rsa and the public key in $HOME/.ssh/id_rsa.pub in the user’s home directory. The user should then copy the contents of id_rsa.pub to the $HOME/.ssh/authorized_keys file in his or her home directory on the remote machine.
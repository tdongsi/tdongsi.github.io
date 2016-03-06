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

In the following instructions, the example machine hostname is `frak16`, with username `oqa` in the domain `OBJY`.

(1) Install OpenSSH for Windows to a machine, e.g., `frak16` at the following location `SSH_DIR=C:\space\cuongd\OpenSSH`.
Use OpenSSH installer from [here](http://www.mls-software.com/opensshd.html).
Do NOT use OpenSSH for Windows from SourceForge, which is outdated, even though many top links from Google search "OpenSSH windows" point to it.
Select "Configure as Domain User" when installing.

(2) In the `PATH` environment variable, make sure that `$(SSH_DIR)\bin` folder comes before MKS and Cygwin's bins folder, if applicable. 
We need to use OpenSSH version of `chmod` and `chown`.

(3) Edit the file `etc/passwd` inside `SSH_DIR` (defined above). 
Make sure the home directory for your username is present and in **Cygwin notation**, e.g., "/cygdrive/c/space/oqa" for user `oqa`.
Make sure there is only one `oqa` user, like `U-OBJY\oqa` (domain user) for `OBJY` domain. 
Delete other `oqa` users such as local users if needed.

```
oqa:unused_by_nt/2000/xp:13331:10513:oqa,U-OBJY\oqa,S-1-5-21-343818398-1708537768-1417001333-3331:/cygdrive/c/space/oqa:/bin/switch
```

(4) Edit `$(SSH_DIR)\etc\banner.txt` to include welcome message that you prefer, to make it less verbose and more informative. I would change it to include the current host name to indicate which host is currently connected.

(5a) Run the following command for a test run:

```
C:\space\cuongd\OpenSSH>usr\sbin\sshd -d -d -d
```

(5b) Use ssh from another host (as client) to test connection. You will have to enter username and password to connect to `frak16` from this client.

``` plain From another machine as client
ssh username@hostname -v

### Example
ssh oqa@frak16 -v
```

If the client is Windows and using OpenSSH, make sure the client's `etc/ssh_config` file in its OpenSSH installation folder is as follows:

``` plain ssh_config

# Site-wide defaults for various options

# Host *
#   ForwardAgent no
#   ForwardX11 no
#   RhostsAuthentication no
#   RhostsRSAAuthentication yes
#   RSAAuthentication yes
#   PasswordAuthentication yes
#   FallBackToRsh no
#   UseRsh no
#   BatchMode no
#   CheckHostIP yes
#   StrictHostKeyChecking yes
#   IdentityFile ~/.ssh/identity
#   IdentityFile ~/.ssh/id_dsa
IdentityFile /cygdrive/c/space/cuongd/.ssh/id_rsa    <--- Verify THIS
#   Port 22
#   Protocol 2,1
#   Cipher blowfish
#   EscapeChar ~
``` 

(6) After making sure the SSH is installed and working properly on `frak16`, run the following in a Command prompt with Admin power to start SSH as a service:

```
net start opensshd
```

Now, you can connect to this Windows machine `frak16` using password authentication.

### Set up public-key SSH

### Troubleshooting

#### Ownership of `.ssh` folder

You might encounter this problem when configuring public-key authentication. 
If you try to run the server in debug mode, you might see the following messages:

``` plain SSH server output in debug mode (sshd -d -d -d)
debug2: input_userauth_request: try method publickey
debug1: test whether pkalg/pkblob are acceptable
debug1: temporarily_use_uid: 13331/10513 (e=13331/10513)
debug1: trying public key file /cygdrive/c/space/oqa/.ssh/authorized_keys
debug3: secure_filename: checking '/cygdrive/c/space/oqa/.ssh'
Authentication refused: bad ownership or modes for directory /cygdrive/c/space/o
qa/.ssh
```

In this case, it's an ownership problem on the SSH server. 
You can try another location for `.ssh` folder on the SSH server to see if it resolves the problem.
In most cases, you can manually fix the above problem by using the following commands:

``` plain
### Set the ownership to user oqa
c:\space\oqa>chown -R oqa .
c:\space\oqa>chmod -R 700 .ssh
c:\space\oqa\.ssh>chmod 600 authorized_keys
```

Note that `chmod` from OpenSSH must be used, instead of `chmod` from MKS or Cygwin. 
In addition, if there is a Local User `oqa`, remove that user so that `chown` will assign ownership to Domain User `oqa`.

#### Outdated SSH installer

```
C:\space\cuongd>scp test.txt oqa@frak16:/cygdrive/c/space/oqa

Received disconnect from 172.21.62.116: 2: fork failed: Resource temporarily una
vailable
lost connection
```

If you see errors like this, you probably used OpenSSH installer from Sourceforge. 
That installer is out-dated and buggy. 
Use the latest installer from [here](http://www.mls-software.com/opensshd.html) instead.

#### File transfer

File transfer:
Putty:
C:\space\cuongd>pscp -i C:\space\cuongd\.ssh\id_rsa_putty.ppk test.txt oqa@frak16:/cygdrive/c/space/oqa
http://stackoverflow.com/questions/16275545/send-commands-to-linux-terminal-with-putty

Error: Unable to use key file "C:\space\cuongd\.ssh\id_rsa" (OpenSSH SSH-2 private key)
To convert an OpenSSH private key to Putty private key:
http://www.cnx-software.com/2012/07/20/how-use-putty-with-an-ssh-private-key-generated-by-openssh/

OpenSSH: the disadvantage is you have to enter passphrase.
C:\space\cuongd>scp -i C:\space\cuongd\.ssh\id_rsa test.txt oqa@frak16:/cygdrive/c/space/oqa

Since OpenSSH for Windows is extracted from Cygwin, trying Cygwin-style command turns out to be a good idea.
This command allows passwordless file transfer:
C:\space\cuongd>scp -i /cygdrive/c/space/cuongd/.ssh/id_rsa test.txt oqa@frak16:/cygdrive/c/space/oqa

### Links

1. [Latest OpenSSH installer](http://www.mls-software.com/opensshd.html)



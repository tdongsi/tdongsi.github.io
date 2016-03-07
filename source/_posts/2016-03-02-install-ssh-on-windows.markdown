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

In the following instructions, the example machine hostname (SSH server) is `frak16`, with username `oqa` in the domain `OBJY`.
Sometimes, another machine (client) is used to connect to this `frak16` machine to test connection settings.

(1) Install OpenSSH for Windows to the SSH server, e.g., `frak16`, at the following location `SSH_DIR=C:\space\oqa\OpenSSH`.
Use OpenSSH installer from [here](http://www.mls-software.com/opensshd.html).
Do NOT use OpenSSH for Windows from Sourceforge, which is outdated, even though many top links from Google search "OpenSSH windows" point to it.
Select "Configure as Domain User" when installing.

(2) In the `PATH` environment variable, make sure that `$(SSH_DIR)\bin` folder comes before MKS and Cygwin's bins folder, if applicable. 
We need to use OpenSSH version of `chmod` and `chown`.

(3) Edit the file `etc/passwd` inside `SSH_DIR` (defined above). 
Make sure that the home directory for your username is present and in **Cygwin notation**, e.g., "/cygdrive/c/space/oqa" for user `oqa`.
Make sure there is only one `oqa` user, like `U-OBJY\oqa` (domain user) for `OBJY` domain. 
Delete other `oqa` users such as local users if needed.

```
oqa:unused_by_nt/2000/xp:13331:10513:oqa,U-OBJY\oqa,S-1-5-21-343818398-1708537768-1417001333-3331:/cygdrive/c/space/oqa:/bin/switch
```

(4) Edit `$(SSH_DIR)\etc\banner.txt` to include welcome message that you prefer, to make it less verbose and more informative. I would change it to include the current host name to indicate which host is currently connected.

(5a) (Optional but recommended) Run SSH server is debug mode to verify that settings are correct. Run the following command for a test run:

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

(1) If the client is already set up, it should have its public key file. Copy content of that file to `$(HOME_DIR)\.ssh\authorized_keys` file on the SSH server (e.g., `frak16`).

If you don't have the public key file for the client, run `ssh-keygen -t rsa` on the client machine. 
The client machine's public key file has the name like "id_rsa.pub".

(2) On the SSH server (e.g., `frak16`), edit `$(SSH_DIR)\etc\sshd_config` to enable PubkeyAuthentication. The following lines must be enabled:

``` plain sshd_config
RSAAuthentication yes
PubkeyAuthentication yes
```

(3) Recursively from `$(HOME_DIR)`, use `chown` to set ownership to `oqa` and `chmod` to set all folders and files in `$(HOME_DIR)\.ssh` to read-only.

``` plain Set ownership and access
### Set the ownership to user oqa
c:\space\oqa>chown -R oqa .
c:\space\oqa>chmod -R 700 .ssh
c:\space\oqa\.ssh>chmod 600 authorized_keys
```

(4) Run SSH server in debug mode again to verify that public-key SSH settings are correct. 
Run this command "ssh oqa@frak16 'ipconfig'" from the client machine and verify that no password is required.

(5) Start SSH server permanently by running, in an elevated Command Prompt. 
As of 2015 Feb, I tried running SSH as a Windows service but it does not work reliably.

``` plain Start SSH
$(SSH_DIR)\usr\sbin\sshd.exe
```

### Troubleshooting

Some of the most frequently encountered problems are discussed in this section.

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

``` plain
C:\space\cuongd>scp test.txt oqa@frak16:/cygdrive/c/space/oqa

Received disconnect from 172.21.62.116: 2: fork failed: Resource temporarily una
vailable
lost connection
```

If you see errors like this, you probably used OpenSSH installer from Sourceforge. 
That installer is outdated and buggy. 
Use the latest installer from [here](http://www.mls-software.com/opensshd.html) instead.

#### Cannot bind any address

You might find the following error message when connecting to an SSH server running in debug mode.

``` plain
debug1: rexec_argv[3]='-d'
debug2: fd 3 setting O_NONBLOCK
debug3: sock_set_v6only: set socket 3 IPV6_V6ONLY
debug1: Bind to port 22 on ::.
Bind to port 22 on :: failed: Address already in use.
debug2: fd 3 setting O_NONBLOCK
debug1: Bind to port 22 on 0.0.0.0.
Bind to port 22 on 0.0.0.0 failed: Address already in use.
Cannot bind any address.
```

If you installed Cygwin and/or MKS on your Windows SSH server, their SSH services (sshd for Cygwin and secshd for MKS) are probably using the port 22.
Verify that by using the following command in Windows:

``` plain Check service usage
C:\space\cuongd\OpenSSH>netstat -b -a

Active Connections

  Proto  Local Address          Foreign Address        State
  TCP    0.0.0.0:22             frak15:0               LISTENING
[secshd.exe]
  TCP    0.0.0.0:23             frak15:0               LISTENING
[telnetd.exe]
  TCP    0.0.0.0:135            frak15:0               LISTENING
  RpcSs
[svchost.exe]
```

You can turn off SSH services from Cygwin and MKS by going to Computer > Manage > Go to Services > Stop the relevant service (Windows 7).

#### File transfer

If you installed `putty` on Windows, note that you CANNOT simply use `pscp` (that is included with `putty` installation) to transfer file to another Windows machine with OpenSSH.

``` plain PSCP error
C:\space\cuongd>pscp -i C:\space\cuongd\.ssh\id_rsa_putty test.txt oqa@frak16:/cygdrive/c/space/oqa
Error: Unable to use key file "C:\space\cuongd\.ssh\id_rsa" (OpenSSH SSH-2 private key)
```

You have to convert the OpenSSH's generated private key to a Putty private key, as detailed [here](http://www.cnx-software.com/2012/07/20/how-use-putty-with-an-ssh-private-key-generated-by-openssh/).

An alternative is to use `scp` that is included with the OpenSSH installation. Note that this might not work (you still have to enter your password):

``` plain This will not work. Password required.
C:\space\cuongd>scp -i C:\space\cuongd\.ssh\id_rsa test.txt oqa@frak16:/cygdrive/c/space/oqa
```

Since OpenSSH for Windows is extracted from Cygwin, trying Cygwin-style command turns out to be a good idea. This command allows password-less file transfer:

``` plain Password NOT required.
C:\space\cuongd>scp -i /cygdrive/c/space/cuongd/.ssh/id_rsa test.txt oqa@frak16:/cygdrive/c/space/oqa
```

Note that files transferred over `scp` may not be readable (mode 000), regardless of file mode on the sending host. 
Therefore, remember to `chmod a+r` on the receiving host after file transfer, especially in an automation script, or you'll get errors related to file access/file not found.

#### Other troubleshooting tips

* You may miss adding/setting some environment variables, e.g., `PATH`. After editing environment variables, you may need to restart your SSHD on a **new** Command Prompt windows to have those new environment variables in effect.
* Remember to disable firewall on Windows machines.

### Links

1. [Latest OpenSSH installer](http://www.mls-software.com/opensshd.html)
2. [Use Putty with an SSH private key generated by OpenSSH](http://www.cnx-software.com/2012/07/20/how-use-putty-with-an-ssh-private-key-generated-by-openssh/)
1. [And old tutorial](http://www.worldgoneweb.com/2011/installing-openssh-on-windows-7/): uses an old OpenSSH installer from Sourceforge. Most of the steps are not needed in the new installers.



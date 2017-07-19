---
layout: post
title: "SSH cookbook: ssh"
date: 2015-05-11 13:45:35 -0700
comments: true
categories: 
- Security
- Bash
---

This blog lists some recipes that is related to `ssh` commands.

<!--more-->

### Quick recipes

Recipe 1: [link](https://askubuntu.com/questions/53553/how-do-i-retrieve-the-public-key-from-a-ssh-private-key)

``` plain Recipe 1: Generate public key from private key
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub
```

Recipe 2: [link](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#verify-key-pair-fingerprints)

``` plain Recipe 2: Show fingerprint of the private key in MD5 format (used by Github, AWS)
openssl rsa -in ~/.ssh/id_rsa -pubout -outform DER | openssl md5 -c
```

Recipe 3: [link](https://serverfault.com/questions/132970/can-i-automatically-add-a-new-host-to-known-hosts).

``` plain Recipe 3: Add new hosts to known_hosts file
ssh-keyscan -H [ip_address] >> ~/.ssh/known_hosts
ssh-keyscan -H [hostname] >> ~/.ssh/known_hosts
```

### `-R` and `-L` of `ssh`

Those options stands for remote and local port forwarding.
There are blog posts explain these options better than [this](https://unix.stackexchange.com/questions/115897/whats-ssh-port-forwarding-and-whats-the-difference-between-ssh-local-and-remot#).
The awesome answer and sketches are reproduced here for occasional review:

{% img center /images/bash/LocalForwarding.png 600 500 %}

{% img center /images/bash/RemoteForwarding.png 490 500 %}

``` plain Example 1
ssh -L 80:localhost:80 SUPERSERVER
```

In Example 1, you specify that a connection made to the local port 80 is to be forwarded to port 80 on SUPERSERVER. 
That means if someone connects to your computer with a webbrowser, he gets the response of the webserver running on SUPERSERVER. 
You, on your local machine, have no webserver running.

``` plain Example 2
ssh -R 80:localhost:80 tinyserver
```

In Example 2, you specify, that a connection made to the port 80 of tinyserver is to be forwarded to port 80 on your local machine. 
That means if someone connects to the small and slow server with a webbrowser, he gets the response of the webserver running on your local machine. 
The tinyserver, which has not enough diskspace for the big website, has no webserver running. 
But people connecting to tinyserver think so.

Other things could be: The powerful machine has five webservers running on five different ports. 
If a user connects to one of the five tinyservers at port 80 with his webbrowser, the request is redirected to the corresponding webserver running on the powerful machine. 
That would be

``` plain Example 3 (before)
ssh -R 80:localhost:30180 tinyserver1
ssh -R 80:localhost:30280 tinyserver2
etc.
```

Or maybe your machine is only the connection between the powerful and the small servers. 
Then it would be (for one of the tinyservers that play to have their own webservers):

``` plain Example 3 (after)
ssh -R 80:SUPERSERVER:30180 tinyserver1
ssh -R 80:SUPERSERVER:30280 tinyserver2
etc
```

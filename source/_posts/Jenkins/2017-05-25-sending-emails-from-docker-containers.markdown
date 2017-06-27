---
layout: post
title: "Sending emails from Docker containers"
date: 2017-05-25 13:42:45 -0700
comments: true
categories: 
- Docker
- Jenkins
- Kubernetes
---

In this post, we looks into sending notification emails at the end of CI pipelines in a containerized Jenkins system.

<!--more-->

### Sending emails in standard Jenkins setup

We first look at a typical Jenkins setup, where the Jenkins instance is installed directly on a host machine (VM or bare-metal) and has direct communication to the SMTP server.
For corporate network, you may have to use an SMTP relay server instead.
For those cases, you can configure SMTP communication by [setting up Postfix](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-as-a-send-only-smtp-server-on-ubuntu-14-04).
Its typical settings is defined in */etc/postfix/main.cf* file like this:

``` plain /etc/postfix/main.cf example
# See /usr/share/postfix/main.cf.bak for a commented, more complete version

myhostname = dev-worker-1.example.com
smtpd_banner = $myhostname ESMTP $mail_name
biff = no

# appending .domain is the MUA's job.
append_dot_mydomain = no

# Uncomment the next line to generate "delayed mail" warnings
#delay_warning_time = 4h

readme_directory = no

# TLS parameters
smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
smtpd_use_tls=yes

# See /usr/share/doc/postfix/TLS_README.gz in the postfix-doc package for
# information on enabling SSL in the smtp client.


alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = dev-worker-1.example.com
mydestination = dev-worker-1.example.com, localhost.example.com, localhost
relayhost = smtprelay-prd.example.com
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = localhost
inet_protocols = all
```

We can test the setup by sending a test email with the following command:

``` plain Send a test email
[tdongsi@dev-worker-1 ~]# echo "Test localhost" | mailx -s Test tdongsi@example.com
send-mail: warning: inet_protocols: disabling IPv6 name/address support: Address family not supported by protocol
postdrop: warning: inet_protocols: disabling IPv6 name/address support: Address family not supported by protocol
```

After the `postfix` service is up, Jenkins can be configured to send email with [Mailer plugin](https://wiki.jenkins-ci.org/display/JENKINS/Mailer).
Mail server can be configured in **Manage Jenkins** page, **E-mail Notification** section.
Please visit [this post](http://www.nailedtothex.org/roller/kyle/entry/articles-jenkins-email) for more detailed instructions and screenshots.
We can also test the configuration by sending test e-mail in the same **E-mail Notification** section.

### Sending email from container

Many Jenkins-based CI systems have been containerized and deployed on Kubernetes cluster (in conjunction with [Kubernetes plugin](https://wiki.jenkins-ci.org/display/JENKINS/Kubernetes+Plugin)). 
For email notifications in such CI systems, one option is to reuse `postfix` service, which is usually configured and ready on the Kubernetes nodes, and expose it to the Docker containers.

There are two changes need to be made on Postfix to expose it to Docker containers on one host.

1. Exposing Postfix to the docker network, that is, Postfix must be configured to bind to localhost as well as the docker network.
1. Accepting all incoming connections which come from any Docker containers.

Docker bridge (`docker0`) acts a a bridge between your ethernet port and docker containers so that data can go back and forth.
We achieve the first requirement by adding the IP of `docker0` to `inet_iterfaces`.

``` plain ifconfig example output
[centos@dev-worker-1 ~]$ ifconfig
docker0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1472
        inet 172.22.91.1  netmask 255.255.255.0  broadcast 0.0.0.0
        ether 02:42:88:5f:24:28  txqueuelen 0  (Ethernet)
        RX packets 8624183  bytes 18891507332 (17.5 GiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 15891332  bytes 16911210191 (15.7 GiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

flannel0: flags=4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST>  mtu 1472
        inet 172.22.91.0  netmask 255.255.0.0  destination 172.22.91.0
        unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen 500  (UNSPEC)
        RX packets 10508237  bytes 7051646109 (6.5 GiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 15511583  bytes 18744591891 (17.4 GiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

For the second requirement, the whole docker network as well as localhost should be added to `mynetworks`. 
In our kubernetes setup, the docker network should be `flannel0` and its subnet's CIDR notation is added to the `mynetworks` line:

``` plain Modified "/etc/postfix/main.cf"
# See /usr/share/postfix/main.cf.bak for a commented, more complete version

myhostname = dev-worker-1.example.com
smtpd_banner = $myhostname ESMTP $mail_name
biff = no

# appending .domain is the MUA's job.
append_dot_mydomain = no

# Uncomment the next line to generate "delayed mail" warnings
#delay_warning_time = 4h

readme_directory = no

# TLS parameters
smtpd_tls_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem
smtpd_tls_key_file=/etc/ssl/private/ssl-cert-snakeoil.key
smtpd_use_tls=yes

# See /usr/share/doc/postfix/TLS_README.gz in the postfix-doc package for
# information on enabling SSL in the smtp client.

alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = dev-worker-1.example.com
mydestination = dev-worker-1.example.com, localhost.example.com, localhost
relayhost = smtprelay-prd.example.com
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 172.22.0.0/16
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = localhost, 172.22.91.1
inet_protocols = all
```

Note the differences in `inet_interfaces` and `mynetworks` from the last section.
One can simply enter the Docker container/Kubernetes pod to verify such setup. 
Note that application `mailx` maybe not available in a container since we tend to keep the containers light-weight.
Instead, prepare a `sendmail.txt` file (based on [this](http://docs.blowb.org/setup-host/postfix.html)) with the following SMTP commands and use `nc` to send out the email as shown below.

``` plain Send test email from container
mymac:k8s tdongsi$ kubectl --kubeconfig kubeconfig --namespace jenkins exec -it jenkins-8hgsn -- bash -il

jenkins@jenkins-8hgsn:~/test$ cat sendmail.txt
HELO x
MAIL FROM: test@example.com
RCPT TO: tdongsi@example.com
DATA
From: test@example.com
To: $YOUR_EMAIL
Subject: This is a test

The test is successful

.
quit

jenkins@jenkins-8hgsn:~/test$ nc 172.22.91.1 25 <sendmail.txt
220 dev-worker-1.eng.sfdc.net ESMTP Postfix
250 dev-worker-1.eng.sfdc.net
250 2.1.0 Ok
250 2.1.5 Ok
354 End data with <CR><LF>.<CR><LF>
250 2.0.0 Ok: queued as 1EF9E60C34
221 2.0.0 Bye
``` 

For containerized Jenkins system, mail server can also be configured in same **Manage Jenkins** page, **E-mail Notification** section. 
The only difference is the IP/hostname provided to **SMTP server** option. 
Instead of providing the known SMTP server's IP and host, one should use the IP of `docker0`, as explained above. 
In the case of many nodes in Kubernetes cluster with different `docker0` IP, the Docker container of Jenkins master should reside only on one host and `docker0`'s IP on that host should be used. 

### References

* [Standard email setup in Jenkins](http://www.nailedtothex.org/roller/kyle/entry/articles-jenkins-email)
* [Setup Postfix](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-as-a-send-only-smtp-server-on-ubuntu-14-04)
* [Configure Postfix for Docker Containers](http://docs.blowb.org/setup-host/postfix.html)
* [More on Postfix for Docker Containers](http://satishgandham.com/2016/12/sending-email-from-docker-through-postfix-installed-on-the-host/)

``` plain postfix version used in this post
[tdongsi@dev-worker-1 ~]$ postconf -v | grep mail_version
mail_version = 2.10.1
```

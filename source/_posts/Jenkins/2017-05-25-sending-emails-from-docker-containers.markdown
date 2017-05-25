---
layout: post
title: "Sending emails from Docker containers"
date: 2017-05-25 13:42:45 -0700
comments: true
categories: 
- Docker
- Jenkins
---

Sending email at the end of pipeline in a containerized Jenkins system.

### Sending SMTP email

[Setup Postfix](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-as-a-send-only-smtp-server-on-ubuntu-14-04)

``` plain /etc/postfix/main.cf
# See /usr/share/postfix/main.cf.dist for a commented, more complete version

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
smtpd_tls_session_cache_database = btree:${data_directory}/smtpd_scache
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache

# See /usr/share/doc/postfix/TLS_README.gz in the postfix-doc package for
# information on enabling SSL in the smtp client.

myhostname = dev-worker-1.example.com
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

Test sending email

``` plain Send a test email
[tdongsi@dev-worker-1 ~]# echo "Test localhost" | mailx -s Test tdongsi@example.com
[tdongsi@dev-worker-1 ~]# send-mail: warning: inet_protocols: disabling IPv6 name/address support: Address family not supported by protocol
postdrop: warning: inet_protocols: disabling IPv6 name/address support: Address family not supported by protocol
```


### Sending email from container

There are two changes need to be made on Postfix.

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
In our kubernetes setup, the docker network should be `flannel0`, add this following line below the `mynetworks` lines:

``` plain Modified /etc/postfix/main.cf
# See /usr/share/postfix/main.cf.dist for a commented, more complete version

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
smtpd_tls_session_cache_database = btree:${data_directory}/smtpd_scache
smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache

# See /usr/share/doc/postfix/TLS_README.gz in the postfix-doc package for
# information on enabling SSL in the smtp client.

myhostname = dev-worker-1.example.com
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

Note the differences in `inet_interfaces` and `mynetworks`.

### References

* [Standard email setup in Jenkins](http://www.nailedtothex.org/roller/kyle/entry/articles-jenkins-email)
* [Setup Postfix](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-as-a-send-only-smtp-server-on-ubuntu-14-04)
* [Configure Postfix for Docker Containers](http://docs.blowb.org/setup-host/postfix.html)
* [More on Postfix for Docker Containers](http://satishgandham.com/2016/12/sending-email-from-docker-through-postfix-installed-on-the-host/)

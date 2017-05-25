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

myhostname = dev-worker-1.eng.sfdc.net
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = dev-worker-1.eng.sfdc.net
mydestination = dev-worker-1.eng.sfdc.net, localhost.eng.sfdc.net, localhost
relayhost = smtprelay-prd.ops.sfdc.net
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = localhost
inet_protocols = all
```


### Sending email from container

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

myhostname = dev-worker-1.eng.sfdc.net
alias_maps = hash:/etc/aliases
alias_database = hash:/etc/aliases
myorigin = dev-worker-1.eng.sfdc.net
mydestination = dev-worker-1.eng.sfdc.net, localhost.eng.sfdc.net, localhost
relayhost = smtprelay-prd.ops.sfdc.net
mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 172.22.0.0/16
mailbox_size_limit = 0
recipient_delimiter = +
inet_interfaces = localhost, 172.22.91.1
inet_protocols = all
```

Note the differences in `inet_interfaces` and `mynetworks`.

### References

* http://docs.blowb.org/setup-host/postfix.html
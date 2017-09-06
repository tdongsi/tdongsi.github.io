---
layout: post
title: "Securing Jenkins with NGINX"
date: 2017-09-05 23:41:23 -0700
comments: true
categories: 
- Security
- Jenkins
---

Demo "Securing a Jenkins Instance" at Jenkins Booth in Jenkins World 2017 by Claudiu Guiman.

{% blockquote %}
A set of minimum steps every Jenkins Admin should follow so his public-facing Jenkins instance doesn’t turn into a Bitcoin mine.
{% endblockquote %}

<!--more-->

``` plain nginx configuration
server {
    listen 80;
    server_name demo-001.eastus.cloudapp.azure.com;
    location / {
        proxy_set_header        Host $host:$server_port;
        proxy_set_header        X-Real-IP $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header        X-Forwarded-Proto $scheme;
        proxy_pass              http://localhost:8080;
        proxy_redirect          http://localhost:8080 http://demo-001.eastus.cloudapp.azure.com;
        proxy_read_timeout      90;
    }

    # block requests to /cli
    location /cli {
        deny all;
    }

    # block requests to /login
    location ~ /login* {
        deny all;
    }
}
```

``` plain Running nginx
$ cp ~/demo/default /etc/nginx/sites-enabled/default
$ sudo service nginx restart
$ sudo ufw deny 8080
```
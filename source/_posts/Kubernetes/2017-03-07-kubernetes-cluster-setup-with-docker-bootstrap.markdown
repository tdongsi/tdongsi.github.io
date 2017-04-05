---
layout: post
title: "Kubernetes: Cluster setup with Docker Bootstrap"
date: 2017-03-07 14:51:07 -0800
comments: true
categories: 
---

### Overview




### Output

```
ExecStart=/usr/bin/docker daemon -H unix:///var/run/docker-bootstrap.sock \
    --exec-opt native.cgroupdriver=systemd \
    --pidfile=/var/run/docker-bootstrap.pid \
    --storage-driver=devicemapper --graph=/var/lib/docker-bootstrap \
    --exec-root=/var/run/docker-bootstrap \
    --log-driver=journald \
    --live-restore \
    --tlscacert=/etc/docker/ca.pem \
    --tlscert=/etc/docker/cert.pem \
    --tlskey=/etc/docker/key.pem \
    --iptables=false \
    --ip-masq=false \
    --bridge=none
```

``` plain
[root@k8s-master-1 ~]# docker -H unix:///var/run/docker-bootstrap.sock ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
[root@k8s-master-1 ~]# docker ps
Cannot connect to the Docker daemon. Is the docker daemon running on this host?
```

### Some useful commands

Empty the content of a file before copy-and-pasting or redirecting content `>>` into a file.

``` plain Empty the content of a file
[root@k8s-master-1 ~]# echo -n | tee /etc/systemd/system/docker-bootstrap.service
```


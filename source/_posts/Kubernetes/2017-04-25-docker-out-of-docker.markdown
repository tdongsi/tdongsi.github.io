---
layout: post
title: "Docker out of Docker"
date: 2017-04-25 10:42:04 -0700
comments: true
categories: 
- Docker
- Kubernetes
- Jenkins
---

### Docker in Docker vs Docker out of Docker

Docker in Docker

https://blog.docker.com/2013/09/docker-can-now-run-within-docker/
https://github.com/jpetazzo/dind

### Troubleshooting

Problem description.

By default, a unix domain socket (or IPC socket) is created at `/var/run/docker.sock`, requiring either root permission, or docker group membership.

For illustration, the installation steps in Ubuntu are expected to be like this:

```
# Install from Web
sudo curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker jenkins

# Install from apt
sudo apt-get update
sudo apt-get install -y docker-engine
sudo usermod -aG docker jenkins
```

Example Dockerfile (from [here](http://stackoverflow.com/questions/31466812/access-docker-sock-from-inside-a-container)).
``` plain Dockerfile
FROM jenkins

USER root
ENV DEBIAN_FRONTEND=noninteractive
ENV HOME /home/jenkins
ENV DOCKER_VERSION=1.9.1-0~trusty

RUN apt-get update \
  && apt-get install -y docker-engine=$DOCKER_VERSION \
  && rm -rf /var/lib/apt/lists/*

RUN usermod -a -G docker jenkins
```

The last step `usermod` comes from the script instruction itself: "If you would like to use Docker as a non-root user, you should now consider adding your user to the "docker" group".


### `groupadd` examples

The following example creates a new group called apache

```
$ groupadd apache
```

Make sure it is created successfully.

```
# grep apache /etc/group
apache:x:1004:
```

If you don’t specify a groupid, Linux will assign one automatically.
If you want to create a group with a specific group id, do the following.

```
$ groupadd apache -g 9090

$ grep 9090 /etc/group
apache:x:9090:
```

Group account information is stored in `/etc/group`.

### References

* [dockerd](https://docs.docker.com/engine/reference/commandline/dockerd/)
* [groupadd man pages](https://linux.die.net/man/8/groupadd)
* [groupadd examples](http://linux.101hacks.com/unix/groupadd/)
* [chown examples](http://www.thegeekstuff.com/2012/06/chown-examples/)
* [find files with group name or ID](https://www.unixtutorial.org/2008/06/find-files-which-belong-to-a-user-or-unix-group/)

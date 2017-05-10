---
layout: post
title: "Troubleshooting Docker-out-of-Docker"
date: 2017-04-26 16:24:24 -0700
comments: true
published: false
categories: 
- Docker
- Kubernetes
---

### Troubleshooting

Problem description: We are using "Docker out of Docker" approach to build Docker images in our containerized Jenkins slaves.
However, we got hit by the following issues when reusing a Jenkins slave container image.

``` plain Error message when running Docker
+ docker images
Cannot connect to the Docker daemon. Is the docker daemon running on this host?
```

The direct cause of this error message is that the socket to docker daemon does not have the right permission (incorrect group ID).

TODO: https://forums.docker.com/t/cannot-connect-to-the-docker-daemon-is-the-docker-daemon-running-on-this-host/8925

The current user (`jenkins` in the example) must have permissions to talk to `/var/run/docker.sock` on that system.
By convention, that permission is given to `root` user or users in `docker` group. 
However, the following commands show that it is not the case.

``` plain Show GID of docker group
+ ls -l /var/run/docker.sock
 
srw-rw----. 1 root 992 0 Mar 14 00:57 /var/run/docker.sock
+ cat /etc/group
...
docker:x:999:jenkins
```

The expectation is:

```
+ ls -l /var/run/docker.sock
srw-rw----. 1 root docker 0 Mar 14 00:57 /var/run/docker.sock
```

This is due to the container is built inside another k8s cluster. 
The group `docker` happens to have the group ID 999 on that k8s cluster.
The user `jenkins`, under which Jenkins pipeline is executed, does not have the permission to access that socket `/var/run/docker.sock`.

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

TODO
* https://github.com/docker/compose/issues/1214
* http://stackoverflow.com/questions/31466812/access-docker-sock-from-inside-a-container
* https://github.com/jenkinsci/docker/issues/196
* https://github.com/jhipster/generator-jhipster/issues/4804
* https://unix.stackexchange.com/questions/33844/change-gid-of-a-specific-group
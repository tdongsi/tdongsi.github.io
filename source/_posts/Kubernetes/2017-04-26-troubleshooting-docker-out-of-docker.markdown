---
layout: post
title: "Troubleshooting Docker-out-of-Docker"
date: 2017-04-26 16:24:24 -0700
comments: true
published: true
categories: 
- Docker
- Kubernetes
- Jenkins
---

In this blog post, we are using ["Docker out of Docker" approach](/blog/2017/04/23/docker-out-of-docker/) to build Docker images in our containerized Jenkins slaves.
We look into a problem usually encountered in that approach, especially when reusing a Docker image for another Kubernetes cluster.

### Problem description

We got the following error when running Docker inside a Jenkins slave container.

``` plain Error message when running Docker
+ docker images
Cannot connect to the Docker daemon. Is the docker daemon running on this host?
```

### Discussion

In summary, for ["Docker out of Docker" approach](/blog/2017/04/23/docker-out-of-docker/), the basic requirements to enable building Docker images in a containerized Jenkins slave is:

1. You'll need to mount "/var/run/docker.sock" as a volume at "/var/run/docker.sock".
1. Having `docker` CLI installed in the containerized Jenkins slave.
1. Make sure "/var/run/docker.sock" has the right permission inside the Jenkins slave container: readable for the current user (e.g., user `jenkins`) or in "docker" group.

The direct cause of the above error message "Cannot connect to the Docker daemon" is that the socket "/var/run/docker.sock" to `docker` daemon on that Jenkins slave does not have the right permission for the current user (`jenkins` in the example).
By convention, the read permission to that Unix domain socket "/var/run/docker.sock" is given to `root` user or users in `docker` group. 
The following commands verify that it is not:

``` plain Show GID of docker group
+ ls -l /var/run/docker.sock
 
srw-rw----. 1 root 992 0 Mar 14 00:57 /var/run/docker.sock
+ cat /etc/group
...
docker:x:999:jenkins
```

The expected output of the above `ls` command is as follows:

``` plain Expected output
+ ls -l /var/run/docker.sock
srw-rw----. 1 root docker 0 Mar 14 00:57 /var/run/docker.sock
```

### Resolving problem

To resolve the problem, simply entering the Docker image, update its `/etc/group` file with the correct GID for `docker` group.
In the example above, the line "docker:x:999:jenkins" should be updated to "docker:x:992:jenkins" to make it work.
It's recommended to run `docker commit` to save the modified container as a new Docker image and push it to Docker registry (similar process in [this post](http://localhost:4000/blog/2017/01/25/docker-root-user-in-a-pod/)).

The root cause of the problem is that the Docker image of Jenkins slave is built inside another Kubernetes cluster (see example Dockerfile below). 
The group `docker` happens to have the group ID 999 on that Kubernetes cluster.

``` plain Dockerfile for installing Docker CLI in Jenkins slave http://stackoverflow.com/questions/31466812/access-docker-sock-from-inside-a-container
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

For illustration, the Docker installation steps in Ubuntu are similar:

``` plain Installing Docker CLI https://docs.docker.com/engine/installation/linux/linux-postinstall/
# Install from Web
sudo curl -sSL https://get.docker.com/ | sh
sudo usermod -aG docker jenkins

# Install from apt
sudo apt-get update
sudo apt-get install -y docker-engine
sudo usermod -aG docker jenkins
```

The last step `usermod` comes from Docker documentation itself: "If you would like to use Docker as a non-root user, you should now consider adding your user to the "docker" group".


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
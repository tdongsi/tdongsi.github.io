---
layout: post
title: "Docker-in-Docker vs Docker-out-of-Docker"
date: 2017-04-23 10:42:04 -0700
comments: true
published: true
categories: 
- Docker
- Kubernetes
- Jenkins
---

In this post, we look into different approaches to the problem of building/pushing Docker images from a containerized Jenkins system.

### Docker-in-Docker & Docker-out-of-Docker

Jenkins as a CI system has been increasingly containerized and ran as a Docker container in production. 
An example setup is to run Jenkins on top of a Kubernetes cluster with Jenkins slaves are created on demand as containers, using [Kubernetes plugin](https://wiki.jenkins-ci.org/display/JENKINS/Kubernetes+Plugin).
The problem in this post arises from how to build/run/push the Docker images insides a Jenkins system that run as a Docker container itself.

"Docker-in-Docker" refers to the approach of installing and running another Docker engine (daemon) inside Docker containers. 
Since Docker 0.6, a "privileged" option is added to allow running containers in a special mode with almost all capabilities of the host machine, including kernel features and devices acccess. 
As a consequence, Docker engine, as a privileged application, can run inside a Docker container itself.

"Docker-in-Docker" is first discussed by Jerome Petazzoni in [this blog post](https://blog.docker.com/2013/09/docker-can-now-run-within-docker/) with example codes. 
However, in [another following blog post](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/), Jerome cautioned against using his "dind" approach in containerized Jenkins.
He pointed out potential problems with his "Docker-in-Docker" approach and how to avoid those by simply bind-mounting the Docker socket into the Jenkins container.
The approach of bind-mounting the Docker socket is later referred as "Docker-out-of-Docker" approach.

### Which one should we use?

As spelled out clearly by "Docker-in-Docker" creator Jerome Petazzoni himself, we should not use Docker-in-Docker, especially in containerized Jenkins systems.
Potential problems include 1) security profile of inner Docker will conflict with one of outer Docker 2) Incompatible file systems (e.g. AUFS inside Docker container).

Instead of trying to run Docker engine inside containers, it is advised to just expose the Docker socket to those containers. 
This can be done by bind-mounting with the `-v` flag:

``` plain Docker out of Docker
docker run -v /var/run/docker.sock:/var/run/docker.sock ...
``` 

By using the above command, we can access the Docker daemon (running on the host machine) from inside the Docker container, and able to start/build/push containers.
The containers that are started inside the Docker container above are effectively "sibling" containers instead of "child" containers since the outer and inner containers are all running on the same host machine.
However, it is important to note that this feels like "Docker-in-Docker" but without any tricky problems associated with this.
And for the purpose of building/running/pushing Docker images in containerized Jenkins systems, this "Docker-out-of-Docker" is exactly all we need.

### Further discussion

The potential issues of "Docker-in-Docker" is extensively discussed by Jerome Petazzoni in his blog post.
However, what's not mentioned is any potential problem of "Docker-out-of-Docker" approach.

In my opinion, one potential issue of "Docker-out-of-Docker" approach is one can access the outer Docker container from the inner container through "/var/run/docker.sock".
In the context of containerized Jenkins system, the outer Docker container is usually Jenkins master with sensitive information.
The inside Docker containers are usually Jenkins slaves that are subject to running all kinds of code which might be malicious.
This means that a containerized Jenkins system can be easily compromised if there is no limit on what's running in Jenkins slaves.

It should be noted that, despite of problems listed by Jerome, "Docker-in-Docker" approach is still a possible choice \*IF\* you know what you are doing. 
Conflict of security profiles can be resolved with the right, careful setup. 
There are work-arounds for incompatible file systems between the containers. 
With the right setup, "Docker-in-Docker" can provide essentially free build isolation and security, which is a must for many, especially in corporates.
However, the ever-present disadvantage of this apporach is long build time for large Docker images since Docker image cache has to be re-populated every run.
As noted by Jerome, this cache is designed for exclusive access by one single Docker daemon at once. 
Trying to link this cache in each container to some common, pre-populated Docker image cache will lead to corrupt image data.

### References

* [Docker-in-Docker](https://blog.docker.com/2013/09/docker-can-now-run-within-docker/)
* [dind](https://github.com/jpetazzo/dind)
* [Docker-out-of-Docker](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/)

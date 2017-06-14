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

In this post, we look into different approaches to the problem of building Docker images from containerized Jenkins system.

### Docker-in-Docker & Docker-out-of-Docker

Jenkins as a CI system has been increasingly containerized and ran as a Docker container in production. 
An example setup is to run Jenkins Docker image in a Kubernetes cluster with Jenkins slaves are created on demand as containers, using [Kubernetes plugin](https://wiki.jenkins-ci.org/display/JENKINS/Kubernetes+Plugin).
The problem in this post arises from how to build the Docker images insides a Jenkins system that run as a Docker container itself.

"Docker-in-Docker" refers to the approach of running another Docker engine inside Docker containers. 
Since Docker 0.6, a "privileged" option is added to allow running containers in a special mode with almost all capabilities of the host machine, including kernel features and devices acccess. 
As a consequence, Docker engine, as a privileged application, can run inside a Docker container itself.

"Docker-in-Docker" is first discussed by Jerome Petazzoni in [this blog post](https://blog.docker.com/2013/09/docker-can-now-run-within-docker/) with example codes. 
However, in [another following blog post](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/), Jerome cautioned against using his "dind" approach in containerized Jenkins.
He pointed out potential problems with his "Docker-in-Docker" approach and how to avoid those by simply bind-mounting the Docker socket into the Jenkins container.
The approach of bind-mounting the Docker socket is later referred as "Docker-out-of-Docker" approach.

### Which one should we use?

As spelled out clearly by "Docker-in-Docker" creator Jerome Petazzoni himself, we should not use Docker-in-Docker, especially in containerized Jenkins systems.

https://gus.my.salesforce.com/_ui/core/chatter/groups/GroupProfilePage?g=0F9B0000000088U&fId=0D5B000000RvNfd&s1oid=00DT0000000Dpvc&s1nid=000000000000000&emkind=chatterGroupDigest&s1uid=005B0000002FEnp&emtm=1491723893028&fromEmail=1&s1ext=0



### References

* [Docker-in-Docker](https://blog.docker.com/2013/09/docker-can-now-run-within-docker/)
* [dind](https://github.com/jpetazzo/dind)
* [Docker-out-of-Docker](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/)

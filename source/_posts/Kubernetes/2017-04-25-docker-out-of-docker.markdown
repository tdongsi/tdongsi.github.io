---
layout: post
title: "Docker-in-Docker vs Docker-out-of-Docker"
date: 2017-04-25 10:42:04 -0700
comments: true
published: false
categories: 
- Docker
- Kubernetes
- Jenkins
---

In this post, we look into different approaches to the problem of building Docker images from containerized Jenkins system.

### Docker-in-Docker vs Docker-out-of-Docker

TODO: Context

TODO: "Docker-in-Docker" refers to running another Docker engine inside Docker containers.

How to approach building Docker images from containerized Jenkins slaves.


We should not use Docker-in-Docker approaches.

https://gus.my.salesforce.com/_ui/core/chatter/groups/GroupProfilePage?g=0F9B0000000088U&fId=0D5B000000RvNfd&s1oid=00DT0000000Dpvc&s1nid=000000000000000&emkind=chatterGroupDigest&s1uid=005B0000002FEnp&emtm=1491723893028&fromEmail=1&s1ext=0



### References

* [Docker-in-Docker](https://blog.docker.com/2013/09/docker-can-now-run-within-docker/)
* [dind](https://github.com/jpetazzo/dind)
* [Docker-out-of-Docker](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/)

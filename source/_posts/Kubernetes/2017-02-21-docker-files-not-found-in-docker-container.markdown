---
layout: post
title: "Docker: Files not found in Docker container"
date: 2017-02-21 15:14:43 -0800
comments: true
published: true
categories: 
- Docker
---

In this post, we look into a perplexing issue that happens often when we try to extend an offical image.
In summary, there is currently no way to add additional content into `VOLUME` directory in a trivial way. 
If you unknowingly adds files into a folder that has been used as a `VOLUME` mount point in a Docker image or one of its base images, the files cannot be found for seemingly no reason.

<!--more-->

### Problem description

Let's say we created the following Dockerfile for container, extending on top of a base Docker image:

``` plain Dockerfile of the extended image
FROM docker.registry.company.net/base
MAINTAINER myemail@company.net

RUN ssh-keyscan -H github.company.net >> /home/jenkins/.ssh/known_hosts

RUN mkdir -p /home/jenkins/.m2 /home/jenkins/store
COPY settings.xml /home/jenkins/.m2/settings.xml

RUN openssl s_client -connect nexus.company.net:443 < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /home/jenkins/public.crt \
    && /opt/jdk-latest/jre/bin/keytool -import -noprompt -storepass change_this -alias nexus.company.net -keystore /home/jenkins/cacerts -file /home/jenkins/public.crt
```

When we try to build the above image with `docker build`, we should expect several files dropped into the home `/home/jenkins` folder.
In fact, we can add several `echo` commands into the above Dockerfile to verify in the build log that the files are actually created.
However, when we start running a container from this new Docker image using `docker run`, the files simply don't exist in `/home/jenkins`.

This was very perplexing at first.
Struggling with different options of rebuilding (`docker build`) and re-running (`docker run`) gives no different outcomes.
It eventually turns out that `/home/jenkins` is mounted as a volume in the `base` image or one of its base images.
If you have access to the base images' Dockerfiles, you should expect to find the following lines in one of the base Dockerfiles:

``` plain Base Dockerfile
...
VOLUME /home/jenkins
WORKDIR /home/jenkins
...
```

Otherwise, you can verify with the following `docker inspect` command when the Docker container is still running:

``` plain Show Volumes
mymac:docker tdongsi$ docker inspect --format { {.Config.Volumes} } 683bb8ce246a
map[/home/jenkins:{}]
```

This problem is already seen and reported in [this issue](https://github.com/docker/docker/issues/3639).
There have been suggestions that `VOLUME` directive in Dockerfile is a mistake. 
It should be an option/directive when running `docker run`, not when building images.

### Resolving problem

The above problem can be resolved by simply adding files into another path that has NOT been used as VOLUME.
If the specific `VOLUME`ed path (`/home/path` in the example) must be used, you can also use `docker copy` to add files into a running container (see [last post](/blog/2017/02/09/docker-copy-file-into-a-container/)).

### References

* [Reported issue](https://github.com/docker/docker/issues/3639)
* [Work around](http://l33t.peopleperhour.com/2015/02/18/docker-extending-official-images/)
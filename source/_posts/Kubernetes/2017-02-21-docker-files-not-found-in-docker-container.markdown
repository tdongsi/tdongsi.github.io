---
layout: post
title: "Docker: Files not found in Docker container"
date: 2017-02-21 15:14:43 -0800
comments: true
published: false
categories: 
- Docker
---

I have the following Dockerfile:

```
FROM docker.registry.company.net/base
MAINTAINER myemail@company.net

RUN ssh-keyscan -H github.company.net >> /home/jenkins/.ssh/known_hosts

RUN mkdir -p /home/jenkins/.m2 /home/jenkins/store
COPY settings.xml /home/jenkins/.m2/settings.xml

RUN openssl s_client -connect nexus.company.net:443 < /dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /home/jenkins/public.crt \
    && /opt/jdk-latest/jre/bin/keytool -import -noprompt -storepass change_this -alias nexus.company.net -keystore /home/jenkins/cacerts -file /home/jenkins/public.crt
```

When I build the image with `docker build`, the commands in Dockerfile should produce several files that get dropped into the home `/home/jenkins` folder.
In fact, it can be verified in the build log that the files are created when adding additional commands.
However, when I create a container from this image using `docker run`, the files in `/home/jenkins` simply doesn't exist.

Struggling with different options of rebuilding (`docker build`) and re-running (`docker run`) gives no different outcomes.
It eventually turns out that `/home/jenkins` is mounted as a volume in the `base` image or one of its base images.

```
tdongsi-ltm4:W_3703511 tdongsi$ docker inspect --format { {.Config.Volumes} } 683bb8ce246a
map[/home/jenkins:{}]
```

I can find the following lines in one of the base Dockerfiles:

```
...
VOLUME /home/jenkins
WORKDIR /home/jenkins
...
```

This problem is already seen and reported in [this issue](https://github.com/docker/docker/issues/3639).
It happens often when we try to extend an offical image.
There is simply no way to add additional content into `VOLUME` directory in a trivial way.
There have been suggestions that `VOLUME` directive in Dockerfile is a mistake. 
It should be an option/directive when running (`docker run`) not building image.


### References

* [Reported issue](https://github.com/docker/docker/issues/3639)
* [Work around](http://l33t.peopleperhour.com/2015/02/18/docker-extending-official-images/)
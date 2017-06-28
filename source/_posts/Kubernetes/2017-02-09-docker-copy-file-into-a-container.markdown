---
layout: post
title: "Docker: Copy file into a container"
date: 2017-02-09 15:17:19 -0800
comments: true
published: true
categories: 
- Docker
---

In this blog post, we have a running Docker container or a running pod in Kubernetes cluster.
We want to add some files into the running containers to fix some issue, verify, and commit the changes.

<!--more-->

### Best-case scenario: `docker cp`

The most obvious way is to create a Dockerfile and rebuild the Docker image.
The Dockerfile will look like this:

``` plain Dockerfile
FROM olderImage
ADD myfile /path/myfile
...
```

However, in this approach, we need to stop the Docker containers, update, and re-run with the new Docker images. 
It does not work if we want to work with ***running*** containers. 
For running containers, the better way to add files into containers is to copy files into containers.
For the more updated versions of Docker (1.8+), the recommended way for copying is to use [`docker cp` command](https://docs.docker.com/engine/reference/commandline/cp/).

### Copy file directly

`docker cp` does not always work, especially in older versions of Docker.
In older versions of Docker, the `docker cp` command only allowed copying files from a **container** to the **host**.
Only since Docker 1.8, copying files from the host to a container is added. 
You will get some error with unhelpful messages like this in older versions of Docker:

``` plain Unsupported "docker cp"
[centos@comp ~]$ ls maven_3.3.9-3_all.deb
maven_3.3.9-3_all.deb

[centos@comp ~]$ sudo docker cp maven_3.3.9-3_all.deb 9a8d782156ca:/home/jenkins
FATA[0000] Error: Path not specified
[centos@comp ~]$ sudo docker cp ./maven_3.3.9-3_all.deb 9a8d782156ca:/home/jenkins
FATA[0000] Error: Path not specified
[centos@comp ~]$ sudo docker cp ./maven_3.3.9-3_all.deb 9a8d782156ca:/home/jenkins/
FATA[0000] Error: Path not specified
[centos@comp ~]$ sudo docker cp maven_3.3.9-3_all.deb 9a8d782156ca:/home/jenkins/maven_3.3.9-3_all.deb
FATA[0000] Error: Path not specified
```

If you find yourself stuck with older versions of Docker, the alternative is to manually copy the files from hosts filesystem to containers filesystem location.
First, you need to determine where the containers filesystem (volume) is mounted on the host:

``` plain Using inspect to find Volume location
[centos@comp ~]$ sudo docker ps
CONTAINER ID      IMAGE    COMMAND ...
9a8d782156ca

[centos@comp ~]$ sudo docker inspect -f { {.Id} } 9a8d782156ca
9a8d782156ca9a3bd59545a18943de408ca58f42c4389c12e9bb43f4ad239d52

[centos@comp ~]$ sudo docker inspect -f { {.Volumes} } 9a8d782156ca
map[/home/jenkins:/var/lib/docker/vfs/dir/b051cc2b086c53ce436ad82b9332ba79687f3ddcf8ee77e3f8264e7cafe32438]
[centos@comp ~]$ sudo ls /var/lib/docker/vfs/dir/b051cc2b086c53ce436ad82b9332ba79687f3ddcf8ee77e3f8264e7cafe32438
test.txt
```

NOTE: In the shell commands above, there is no space between `{` (space is added for Jekyll blog engine). 
After the mounting path is determined, you can manipulate the container'ss filesystem directly, including copying files into it.

``` plain Directly copy file into containers filesystem
[centos@comp ~]$ sudo cp maven_3.3.9-3_all.deb /var/lib/docker/vfs/dir/b051cc2b086c53ce436ad82b9332ba79687f3ddcf8ee77e3f8264e7cafe32438
```

You can verify such manipulation by `docker exec`-ing into the container and verify the files:

``` plain Before and After
jenkins@9a8d782156ca:~$ ls
test.txt

jenkins@9a8d782156ca:~$ ls
maven_3.3.9-3_all.deb  test.txt
```

### Reference

* [docker cp](https://docs.docker.com/engine/reference/commandline/cp/)
* [Stackoverflow discussion](http://stackoverflow.com/questions/22907231/copying-files-from-host-to-docker-container)

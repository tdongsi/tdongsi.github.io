---
layout: post
title: "Docker: Copy file into a container"
date: 2017-02-09 15:17:19 -0800
comments: true
published: true
categories: 
- Docker
---

We have running docker container.
Want to add files and commit

### Cleanest way: `docker cp`

`docker cp` -> `docker commit` -> `docker push`.

### Copy file directly

`docker cp` does not always work, especially in older versions of Docker.
You will get some error with unhelpful messages like this:

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

In older versions of Docker, the `docker cp` command only allowed copying files from a **container** to the **host**.
Only since Docker 1.8, copying files from the host to a container is added.

``` plain Using inspect to find Volume location
[centos@comp ~]$ sudo docker inspect -f {{.Id}} 9a8d782156ca
9a8d782156ca9a3bd59545a18943de408ca58f42c4389c12e9bb43f4ad239d52

[centos@comp ~]$ sudo docker inspect -f {{.Volumes}} 9a8d782156ca
map[/home/jenkins:/var/lib/docker/vfs/dir/b051cc2b086c53ce436ad82b9332ba79687f3ddcf8ee77e3f8264e7cafe32438]
[centos@comp ~]$ sudo ls /var/lib/docker/vfs/dir/b051cc2b086c53ce436ad82b9332ba79687f3ddcf8ee77e3f8264e7cafe32438
test.txt
[centos@comp ~]$ sudo cp maven_3.3.9-3_all.deb /var/lib/docker/vfs/dir/b051cc2b086c53ce436ad82b9332ba79687f3ddcf8ee77e3f8264e7cafe32438
```

``` plain Before and After
jenkins@9a8d782156ca:~$ ls
test.txt

jenkins@9a8d782156ca:~$ ls
maven_3.3.9-3_all.deb  test.txt
```

### Reference

http://stackoverflow.com/questions/22907231/copying-files-from-host-to-docker-container
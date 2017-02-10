---
layout: post
title: "Docker: Copy file into a container"
date: 2017-02-09 15:17:19 -0800
comments: true
categories: 
- Docker
---

Running docker container.

### Cleanest way

`docker copy` does not always work, especially in the older versions.

```
[centos@kube-worker-2 ~]$ ls maven_3.3.9-3_all.deb
maven_3.3.9-3_all.deb
[centos@kube-worker-2 ~]$ ls -l maven_3.3.9-3_all.deb
-rw-r--r-- 1 centos centos 17356 Feb  9 23:01 maven_3.3.9-3_all.deb
[centos@kube-worker-2 ~]$ sudo docker cp maven_3.3.9-3_all.deb 9a8d782156ca:/home/jenkins
FATA[0000] Error: Path not specified
[centos@kube-worker-2 ~]$ sudo docker cp ./maven_3.3.9-3_all.deb 9a8d782156ca:/home/jenkins
FATA[0000] Error: Path not specified
[centos@kube-worker-2 ~]$ sudo docker cp ./maven_3.3.9-3_all.deb 9a8d782156ca:/home/jenkins/
FATA[0000] Error: Path not specified
[centos@kube-worker-2 ~]$ sudo docker cp maven_3.3.9-3_all.deb 9a8d782156ca:/home/jenkins/maven_3.3.9-3_all.deb
FATA[0000] Error: Path not specified
```

### Rerun with mount

`docker run` with mount

### Copy file directly

```
[centos@kube-worker-2 ~]$ sudo docker inspect -f {{.Id}} 9a8d782156ca
9a8d782156ca9a3bd59545a18943de408ca58f42c4389c12e9bb43f4ad239d52

[centos@kube-worker-2 ~]$ sudo docker inspect -f {{.Volumes}} 9a8d782156ca
map[/home/jenkins:/var/lib/docker/vfs/dir/b051cc2b086c53ce436ad82b9332ba79687f3ddcf8ee77e3f8264e7cafe32438]
[centos@kube-worker-2 ~]$ sudo ls /var/lib/docker/vfs/dir/b051cc2b086c53ce436ad82b9332ba79687f3ddcf8ee77e3f8264e7cafe32438
test.txt
[centos@kube-worker-2 ~]$ sudo cp maven_3.3.9-3_all.deb /var/lib/docker/vfs/dir/b051cc2b086c53ce436ad82b9332ba79687f3ddcf8ee77e3f8264e7cafe32438
```

```
jenkins@9a8d782156ca:~$ ls
test.txt

jenkins@9a8d782156ca:~$ ls
maven_3.3.9-3_all.deb  test.txt
```

### Reference

http://stackoverflow.com/questions/22907231/copying-files-from-host-to-docker-container
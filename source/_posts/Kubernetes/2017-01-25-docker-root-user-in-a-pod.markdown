---
layout: post
title: "Docker: Root user in a pod"
date: 2017-01-25 18:22:51 -0800
comments: true
categories: 
- Docker
- Kubernetes
---

In the following scenario, we have some pod running in Kubernetes cluster.

```
tdongsi-ltm4:kubernetes tdongsi$ kubectl --kubeconfig kubeconfig describe pod jenkins
Name:				jenkins
Namespace:			default
Image(s):			docker.registry.company.net/tdongsi/jenkins:2.23
Node:				kube-worker-1/10.252.158.72
Start Time:			Tue, 24 Jan 2017 16:57:47 -0800
Labels:				name=jenkins
Status:				Running
Reason:
Message:
IP:				172.17.27.3
Replication Controllers:	<none>
Containers:
  jenkins:
    Container ID:	docker://943d6e55038804c8
    Image:		docker.registry.company.net/tdongsi/jenkins:2.23
    Image ID:		docker://242c1836544e5ca31616
    State:		Running
      Started:		Tue, 24 Jan 2017 16:57:48 -0800
    Ready:		True
    Restart Count:	0
    Environment Variables:
Conditions:
  Type		Status
  Ready 	True
Volumes:
  jenkins-data:
    Type:	HostPath (bare host directory volume)
    Path:	/jdata
No events. 
```

For troubleshooting purposes, we sometimes need to enter the container or execute some commands with root privilege.
Sometimes, we simply cannot `sudo` or have the root password.

```
jenkins@jenkins:~$ sudo ls /etc/hosts
[sudo] password for jenkins:
Sorry, try again.
```

Modifying the Docker image to set root password (e.g., by editing `Dockerfile` and rebuild) is sometimes not an option, 
such as when the Docker image is downloaded from another source and read-only.
Moreover, if the container is running in production, we don't want to stop the container while troubleshooting some temporary issues.

I found one way to enter a "live" container as root by using `nsenter`.
In summary, we find the process ID of the target container and provide it to `nsenter` as an argument.
In the case of a Kuberentes cluster, we need to find which Kubernetes slave the pod is running on and log into it to execute the following `docker` commands.

``` plain Finding running container ID and name
[centos@kube-worker-1 ~]$ sudo docker ps
CONTAINER ID        IMAGE                                              COMMAND                CREATED             STATUS              PORTS               NAMES
943d6e5a3bb8        docker.registry.company.net/tdongsi/jenkins:2.23   "/usr/local/bin/tini   25 hours ago        Up 25 hours                             k8s_jenkins.6e7c865_jenkins_default_49e9a163-e299-11e6-a10d-fa163e64b467_40c7167f
fadfc479f24e        gcr.io/google_containers/pause:0.8.0               "/pause"               25 hours ago        Up 25 hours                             k8s_POD.9243e30_jenkins_default_49e9a163-e299-11e6-a10d-fa163e64b467_9434ea19
```

Use `docker inspect` to find the process ID based on the container ID.
The Go template `{ {.State.Pid} }` (NOTE: without space) is used to simplify the output to a single numerical Pid.

``` plain
[centos@kube-worker-1 ~]$ sudo docker inspect --format { {.State.Pid} } 943d6e5a3bb8
9176

[centos@kube-worker-1 ~]$ sudo nsenter --target 9176 --mount --uts --ipc --net --pid
root@jenkins:/# cd ~
root@jenkins:~# vi /etc/hosts
root@jenkins:~# exit
```

For later versions of Docker, the more direct way is to use `docker exec` with the container name shown in `docker ps` output. 
The above example can be simplified as follows:

```
[centos@kube-worker-1 ~]$ sudo docker exec --privileged -it <long_docker_name> bash
```

In that case, we eliminate the need of `nsenter` tool.
However, note that the above `docker exec` might not work for earlier versions of Docker (tested with Docker 1.6) and `nsenter` must be used.

### References

* [nsenter tool](https://github.com/jpetazzo/nsenter)
* [docker exec](https://docs.docker.com/engine/reference/commandline/exec/) manual
* [StackOverflow discussion](http://stackoverflow.com/questions/28721699/root-password-inside-a-docker-container)


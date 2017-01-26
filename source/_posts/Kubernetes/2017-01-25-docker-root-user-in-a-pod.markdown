---
layout: post
title: "Docker: Root user in a pod"
date: 2017-01-25 18:22:51 -0800
comments: true
categories: 
- Docker
- Kubernetes
---

You have some pod running in Kubernetes cluster.

```
tdongsi-ltm4:kubernetes tdongsi$ kubectl --kubeconfig kubeconfig describe pod jenkins
Name:				jenkins
Namespace:			default
Image(s):			ops0-artifactrepo1-0-prd.data.sfdc.net/tdongsi/matrix-jenkins:2.23
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
    Container ID:	docker://943d6e5a3bb8270b5b06b0aa360f3969c005617ec5781dc5319692f5038804c8
    Image:		ops0-artifactrepo1-0-prd.data.sfdc.net/tdongsi/matrix-jenkins:2.23
    Image ID:		docker://242c18370cc82536de0beb13c9da78fe1096a1a1a55a6c9ef936544e5ca31616
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

You need to have root power to troubleshoot.
However, you simply don't have the root password.

```
jenkins@jenkins:~$ sudo ls /etc/hosts
[sudo] password for jenkins:
Sorry, try again.
```

One way to enter the container as root is:

```
[centos@kube-worker-1 ~]$ sudo docker ps
CONTAINER ID        IMAGE                                                                COMMAND                CREATED             STATUS              PORTS               NAMES
943d6e5a3bb8        ops0-artifactrepo1-0-prd.data.sfdc.net/tdongsi/matrix-jenkins:2.23   "/usr/local/bin/tini   25 hours ago        Up 25 hours                             k8s_jenkins.6e7c865_jenkins_default_49e9a163-e299-11e6-a10d-fa163e64b467_40c7167f
fadfc479f24e        gcr.io/google_containers/pause:0.8.0                                 "/pause"               25 hours ago        Up 25 hours                             k8s_POD.9243e30_jenkins_default_49e9a163-e299-11e6-a10d-fa163e64b467_9434ea19
[centos@kube-worker-1 ~]$ docker inspect --format {{.State.Pid}} 943d6e5a3bb8
Get http:///var/run/docker.sock/v1.18/images/943d6e5a3bb8/json: dial unix /var/run/docker.sock: permission denied. Are you trying to connect to a TLS-enabled daemon without TLS?[centos@kube-worker-1 ~]$ sudo !!
sudo docker inspect --format {{.State.Pid}} 943d6e5a3bb8
9176
[centos@kube-worker-1 ~]$ sudo nsenter --target 9176 --mount --uts --ipc --net --pid
root@jenkins:/# cd ~
root@jenkins:~# vi /etc/hosts
root@jenkins:~# exit
```

After Docker 1.6, this might worker

```
[centos@kube-worker-1 ~]$ sudo docker exec --privileged -it k8s_jenkins.6e7c865_jenkins_default_49e9a163-e299-11e6-a10d-fa163e64b467_40c7167f bash
```

### References

* https://github.com/jpetazzo/nsenter
* http://stackoverflow.com/questions/28721699/root-password-inside-a-docker-container
* https://docs.docker.com/engine/reference/commandline/exec/


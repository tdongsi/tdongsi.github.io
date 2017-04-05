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
tdongsi-mac:kubernetes tdongsi$ kubectl --kubeconfig kubeconfig describe pod jenkins
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

After entering the container as `root`, you might want to add the user into sudo group and save the modified Docker image.

```
[centos@kube-worker-3 ~]$ sudo nsenter --target 17377 --mount --uts --ipc --net --pid
root@node-v4:~# cd /home/jenkins
root@node-v4:/home/jenkins# usermod -a -G sudo jenkins
root@node-v4:/home/jenkins# passwd jenkins
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully
root@node-v4:/home/jenkins# exit
logout

[centos@kube-worker-3 ~]$ sudo docker commit --author tdongsi --message "Add Jenkins password" 280e5237cc6a docker.registry.company.net/tdongsi/matrix-jenkins-nodev4-agent:2.80
b1fe6c66195e32fcb8ef4974e3d6228ee2f4cf46ab08dbc074f633d95005941b

[centos@kube-worker-3 ~]$ sudo docker push docker.registry.company.net/tdongsi/matrix-jenkins-nodev4-agent:2.80
The push refers to a repository [docker.registry.company.net/tdongsi/matrix-jenkins-nodev4-agent] (len: 1)
b1fe6c66195e: Image already exists
151c68e860a5: Image successfully pushed
670d6fd894d6: Image successfully pushed
...
```

After that, you can verify `sudo`ing in the new Docker image.

```
tdongsi-mac:~ tdongsi$ docker pull docker.registry.company.net/tdongsi/matrix-jenkins-nodev4-agent:2.80
2.80: Pulling from tdongsi/matrix-jenkins-nodev4-agent
bf5d46315322: Already exists
9f13e0ac480c: Already exists
ebe26e644840: Pull complete
40af181810e7: Pull complete
...

tdongsi-mac:~ tdongsi$ docker run -d --restart=always --entrypoint="java" docker.registry.company.net/tdongsi/matrix-jenkins-nodev4-agent:2.80 -jar /usr/share/jenkins/slave.jar -jnlpUrl http://10.252.78.115/computer/slave/slave-agent.jnlp
dd9c207e2ef1c0520439451b1775b976e3c9e09712f8ca1fb42f1bc082f14809
tdongsi-mac:~ tdongsi$ docker ps
CONTAINER ID        IMAGE                                                                             COMMAND                  CREATED             STATUS              PORTS               NAMES
dd9c207e2ef1        docker.registry.company.net/tdongsi/matrix-jenkins-nodev4-agent:2.80   "java -jar /usr/sh..."   5 seconds ago       Up 4 seconds                            ecstatic_galileo
tdongsi-mac:~ tdongsi$ docker exec -it dd9c207e2ef1 bash
jenkins@dd9c207e2ef1:~$ sudo ls /etc/hosts
[sudo] password for jenkins:
/etc/hosts
jenkins@dd9c207e2ef1:~$ sudo cat /etc/hosts
127.0.0.1	localhost
::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
ff00::0	ip6-mcastprefix
ff02::1	ip6-allnodes
ff02::2	ip6-allrouters
172.17.0.2	dd9c207e2ef1
jenkins@dd9c207e2ef1:~$ exit
exit
```

### References

* [nsenter tool](https://github.com/jpetazzo/nsenter)
* [docker exec](https://docs.docker.com/engine/reference/commandline/exec/) manual
* [StackOverflow discussion](http://stackoverflow.com/questions/28721699/root-password-inside-a-docker-container)


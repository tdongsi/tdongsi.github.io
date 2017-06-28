---
layout: post
title: "Kubernetes: Pod-to-Node Communication Loss"
date: 2017-01-24 15:05:15 -0800
comments: true
published: true
categories: 
- Kubernetes
- Docker
---

This post goes over what happens if we misconfigure `etcd` and `flannel` to use the same network (e.g., "10.252.61.0/16") as the infrastructure (e.g., "10.252.158.72" node). 
This newbie mistake is rare but very perplexing and this post shows how to troubleshoot it with `busybox` container.

<!--more-->

### Problem symptoms

From a pod (e.g., `jenkins`) on one node (e.g., `10.252.158.71`), we cannot communicate with another node (e.g., `10.252.158.72`) even though two nodes can communicate with each other normally.

``` plain
mymac:kubernetes tdongsi$ kubectl --kubeconfig kubeconfig exec -it jenkins -- bash -il
jenkins@jenkins:~$ ping 10.252.158.72
PING 10.252.158.72 (10.252.158.72) 56(84) bytes of data.
^C
--- 10.252.158.72 ping statistics ---
16 packets transmitted, 0 received, 100% packet loss, time 14999ms

jenkins@jenkins:~$ exit
```

Even more perplexing, the pod-to-pod communication is fine (as described right below), even though the second pod is on the same node (e.g., `10.252.158.72`) that the first pod cannot communciate to.

### Troubleshooting with `busybox`

Try to run a test pod `busybox`. 
`jenkins` pod can ping the `busybox` pod, but not the node that `busybox` pod is running on.

```
mymac:kubernetes tdongsi$ kubectl --kubeconfig kubeconfig run busybox \
--image=docker.registry.company.net/tdongsi/busybox --restart=Never --tty -i --generator=run-pod/v1
Waiting for pod default/busybox to be running, status is Pending, pod ready: false
Waiting for pod default/busybox to be running, status is Running, pod ready: false
Waiting for pod default/busybox to be running, status is Running, pod ready: false

mymac:kubernetes tdongsi$ kubectl --kubeconfig kubeconfig exec -it jenkins -- bash -il
jenkins@jenkins:~$ ping 10.252.61.7
PING 10.252.61.7 (10.252.61.7) 56(84) bytes of data.
64 bytes from 10.252.61.7: icmp_seq=1 ttl=62 time=0.540 ms
64 bytes from 10.252.61.7: icmp_seq=2 ttl=62 time=0.186 ms
64 bytes from 10.252.61.7: icmp_seq=3 ttl=62 time=0.177 ms
64 bytes from 10.252.61.7: icmp_seq=4 ttl=62 time=0.161 ms
64 bytes from 10.252.61.7: icmp_seq=5 ttl=62 time=0.187 ms
^C
--- 10.252.61.7 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4000ms
rtt min/avg/max/mdev = 0.161/0.250/0.540/0.145 ms

jenkins@jenkins:~$ ping 10.252.158.72
PING 10.252.158.72 (10.252.158.72) 56(84) bytes of data.
^C
--- 10.252.158.72 ping statistics ---
14 packets transmitted, 0 received, 100% packet loss, time 13000ms
```

In this case, we would use `traceroute` from the `busybox` container to determine when the packets are dropped. 
`10.252.158.72` is IP of the VM. `10.252.100.5` is the IP of the `jenkins` pod.

```
mymac:kubernetes tdongsi$ kubectl --kubeconfig kubeconfig run busybox \
--image=docker.registry.company.net/tdongsi/busybox --restart=Never --tty -i --generator=run-pod/v1

Waiting for pod default/busybox to be running, status is Pending, pod ready: false
Waiting for pod default/busybox to be running, status is Running, pod ready: false
Waiting for pod default/busybox to be running, status is Running, pod ready: false

/ # traceroute 10.252.158.72
traceroute to 10.252.158.72 (10.252.158.72), 30 hops max, 46 byte packets
 1  10.252.61.1 (10.252.61.1)  0.005 ms  0.012 ms  0.001 ms
 2  *  *  *
 3  *  *  *
 4  *  *  *
 5  *  *  *
/ #
/ # traceroute 10.252.100.5
traceroute to 10.252.100.5 (10.252.100.5), 30 hops max, 46 byte packets
 1  10.252.61.1 (10.252.61.1)  0.005 ms  0.004 ms  0.002 ms
 2  *  10.252.100.0 (10.252.100.0)  0.487 ms  0.241 ms
 3  10.252.100.5 (10.252.100.5)  0.141 ms  0.563 ms  0.132 ms
/ # exit
```

For the context, `10.252.100.5` is the IP of the service, as shown in the command below.

```
mymac:private_cloud tdongsi$ kubectl --kubeconfig kubeconfig describe services
Name:			jenkins
Namespace:		default
Labels:			<none>
Selector:		name=jenkins
Type:			NodePort
IP:			10.252.77.85
Port:			http	80/TCP
NodePort:		http	30080/TCP
Endpoints:		10.252.100.5:8080
Session Affinity:	None
No events.
```

### What went wrong?

It's a newbie mistake when configuring Kubernetes.
When setting up `etcd` and configuring it to hold `flannel` configuration, it is important to pick an unused network.
I made a mistake for using `10.252.61.0/16` for flannel when some of my kubernetes nodes has IPs as "10.252.xxx.xxx". 
As a result, kube-proxy services intercept the traffic from the container and thinks its a virtual traffic since my node IP happens to be in the same subnet with `flanneld`.
This leads to pod-to-VM communication loss as described above. 
The solution is simply reset flanneld with another subnet after resetting configruation value in `etcd` to "172.17.0.0/16".

``` plain Update etcd
[centos@kube-master ~]$ etcdctl update /kube-centos/network/config \
"{ \"Network\": \"172.17.0.0/16\", \"SubnetLen\": 24, \"Backend\": { \"Type\": \"vxlan\" } }"

[centos@kube-master ~]$ etcdctl rm --recursive /kube-centos/network/subnets
[centos@kube-master ~]$ etcdctl ls /kube-centos/network
/kube-centos/network/config
```

After this, we can reset and restart `flannel` services on all nodes to use the new network overlay configuration.

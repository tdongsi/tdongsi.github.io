---
layout: post
title: "Kubernetes: Pod-to-Node Communication Loss"
date: 2017-01-24 15:05:15 -0800
comments: true
categories: 
- Kubernetes
- Docker
---

From a pod (e.g., `jenkins`), we cannot communicate with another node (e.g., `10.252.158.72`)

``` plain
tdongsi-ltm4:kubernetes tdongsi$ kubectl --kubeconfig kubeconfig exec -it jenkins -- bash -il
jenkins@jenkins:~$ ping 10.252.158.72
PING 10.252.158.72 (10.252.158.72) 56(84) bytes of data.
^C
--- 10.252.158.72 ping statistics ---
16 packets transmitted, 0 received, 100% packet loss, time 14999ms

jenkins@jenkins:~$ exit
logout
```

Try to run a test pod `busybox`. `jenkins` pod can ping the `busybox` pod, but not the node that `busybox` pod is running on.

```
tdongsi-ltm4:kubernetes tdongsi$ kubectl --kubeconfig kubeconfig run busybox --image=ops0-artifactrepo1-0-prd.data.sfdc.net/tdongsi/busybox --restart=Never --tty -i --generator=run-pod/v1
Waiting for pod default/busybox to be running, status is Pending, pod ready: false
Waiting for pod default/busybox to be running, status is Running, pod ready: false
Waiting for pod default/busybox to be running, status is Running, pod ready: false
Waiting for pod default/busybox to be running, status is Running, pod ready: false
Waiting for pod default/busybox to be running, status is Running, pod ready: false

tdongsi-ltm4:kubernetes tdongsi$ kubectl --kubeconfig kubeconfig exec -it jenkins -- bash -il
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

jenkins@jenkins:~$ exit
logout
```

Use `traceroute` to determine when the packets are dropped. `10.252.158.72` is IP of the VM. `10.252.100.5` is the IP of the `jenkins` pod.

```
tdongsi-ltm4:kubernetes tdongsi$ kubectl --kubeconfig kubeconfig run busybox --image=ops0-artifactrepo1-0-prd.data.sfdc.net/tdongsi/busybox --restart=Never --tty -i --generator=run-pod/v1
Waiting for pod default/busybox to be running, status is Pending, pod ready: false
Waiting for pod default/busybox to be running, status is Running, pod ready: false
Waiting for pod default/busybox to be running, status is Running, pod ready: false
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

tdongsi-ltm4:private_cloud tdongsi$ kubectl --kubeconfig kubeconfig describe services
Name:			jenkins
Namespace:		default
Labels:			<none>
Selector:		name=jenkins
Type:			NodePort
IP:			10.252.77.85
Port:			http	80/TCP
NodePort:		http	30080/TCP
Endpoints:		10.252.100.5:8080
Port:			ssh	12222/TCP
NodePort:		ssh	32222/TCP
Endpoints:		10.252.100.5:12222
Port:			slave	50000/TCP
NodePort:		slave	31500/TCP
Endpoints:		10.252.100.5:50000
Session Affinity:	None
No events.
```

It's a Kubernetes config issue. 
In summary, the reason of pod-to-VM communication loss is that kube-proxy intercepts the traffic from container and thinks its a virtual traffic since my node IP happens to be in the same subnet with flanneld. 
My mistake when configuring flanneld for the kubernetes cluster. 
The solution is simply reset flanneld with another subnet (in etcd).


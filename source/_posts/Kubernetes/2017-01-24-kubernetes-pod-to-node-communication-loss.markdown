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

```
[centos@kube-worker-1 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether fa:16:3e:6c:d9:cc brd ff:ff:ff:ff:ff:ff
    inet 10.252.158.72/26 brd 10.252.158.127 scope global dynamic eth0
       valid_lft 57022sec preferred_lft 57022sec
4: flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN
    link/ether 46:42:d4:b2:5a:08 brd ff:ff:ff:ff:ff:ff
    inet 10.252.61.0/16 scope global flannel.1
       valid_lft forever preferred_lft forever
5: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UP
    link/ether 56:84:7a:fe:97:99 brd ff:ff:ff:ff:ff:ff
    inet 10.252.61.1/24 scope global docker0
       valid_lft forever preferred_lft forever
```

### Update flannel

etcd

```
[centos@kube-controller-1 ~]$ etcdctl update /kube-centos/network/config "{ \"Network\": \"172.17.0.0/16\", \"SubnetLen\": 24, \"Backend\": { \"Type\": \"vxlan\" } }"
[centos@kube-controller-1 ~]$ etcdctl rm --recursive /kube-centos/network/subnets
[centos@kube-controller-1 ~]$ etcdctl ls /kube-centos/network
/kube-centos/network/config
```

Controller

```
[centos@kube-controller-1 ~]$ sudo ls /run/flannel/
docker     subnet.env
[centos@kube-controller-1 ~]$ sudo rm /run/flannel/docker
[centos@kube-controller-1 ~]$ sudo rm /run/flannel/subnet.env
[centos@kube-controller-1 ~]$ sudo ls /run/flannel/
<Nothing>
[centos@kube-controller-1 ~]$ sudo systemctl status etcd

[centos@kube-controller-1 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether fa:16:3e:64:b4:67 brd ff:ff:ff:ff:ff:ff
    inet 10.252.158.71/26 brd 10.252.158.127 scope global dynamic eth0
       valid_lft 63955sec preferred_lft 63955sec
[centos@kube-controller-1 ~]$ sudo systemctl start etcd
[centos@kube-controller-1 ~]$ sudo systemctl start flanneld
[centos@kube-controller-1 ~]$ ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether fa:16:3e:64:b4:67 brd ff:ff:ff:ff:ff:ff
    inet 10.252.158.71/26 brd 10.252.158.127 scope global dynamic eth0
       valid_lft 63938sec preferred_lft 63938sec
7: flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN
    link/ether 92:00:3c:3d:61:52 brd ff:ff:ff:ff:ff:ff
    inet 172.17.83.0/16 scope global flannel.1
       valid_lft forever preferred_lft forever
```

Nodes

```
[centos@kube-worker-3 ~]$ sudo ls /run/flannel/
docker     subnet.env
[centos@kube-worker-3 ~]$ sudo rm /run/flannel/docker
[centos@kube-worker-3 ~]$ sudo rm /run/flannel/subnet.env
[centos@kube-worker-3 ~]$ sudo systemctl stop docker
[centos@kube-worker-3 ~]$ sudo systemctl stop flanneld
[centos@kube-worker-3 ~]$ ip ad
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
    link/ether fa:16:3e:7a:78:0b brd ff:ff:ff:ff:ff:ff
    inet 10.252.158.74/26 brd 10.252.158.127 scope global dynamic eth0
       valid_lft 79103sec preferred_lft 79103sec
4: flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN
    link/ether 4e:7d:37:25:1e:b0 brd ff:ff:ff:ff:ff:ff
    inet 10.252.100.0/16 scope global flannel.1
       valid_lft forever preferred_lft forever
5: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1450 qdisc noqueue state DOWN
    link/ether 56:84:7a:fe:97:99 brd ff:ff:ff:ff:ff:ff
    inet 10.252.100.1/24 scope global docker0
       valid_lft forever preferred_lft forever
[centos@kube-worker-3 ~]$ sudo ip link del docker0
[centos@kube-worker-3 ~]$ sudo ip link del flannel.1
[centos@kube-worker-3 ~]$ for SERVICES in kube-proxy kubelet flanneld docker; do
>     sudo systemctl restart $SERVICES
>     sudo systemctl enable $SERVICES
>     sudo systemctl status $SERVICES
> done
```

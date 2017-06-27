---
layout: post
title: "Kubernetes: kube-router"
date: 2017-05-15 10:52:34 -0700
comments: true
categories: 
- Kubernetes
---

Kubernetes is one of the [most active open-source project](http://www.infoworld.com/article/3118345/cloud-computing/why-kubernetes-is-winning-the-container-war.html) right now. 
I'm trying to keep up with interesting updates from the Kubernetes community.
This `kube-router` project is one of them although I've not get an idea how stable or useful it is. 

{% blockquote %}
Kube-router is a distributed load balancer, firewall and router for Kubernetes. Kube-router can be configured to provide on each cluster node:
* IPVS/LVS based service proxy on each node for ClusterIP and NodePort service types, providing service discovery and load balancing
* an ingress firewall for the pods running on the node as per the defined Kubernetes network policies using iptables and ipset
* a BGP router to advertise and learn the routes to the pod IP's for cross-node pod-to-pod connectivity
{% endblockquote %}

<!--more-->

A few notes on related works in Kubernetes community:

* The most obvious one is `kube-proxy` service, which is included in the standard Kubernetes installations. This `kube-router` can be a replacement for `kube-proxy` in the future.
* Another related work is [IPVS-based in-cluster service load balancing](https://github.com/kubernetes/kubernetes/issues/44063). 
  Huawei presented this work at Kubecon 2016. 
  IIRC, it is implemented as a flag to kube-proxy and considerable performance improvement was reported.

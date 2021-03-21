---
layout: post
title: "Kubernetes operators vs. Kustomize plugins"
date: 2021-03-21 03:42:42 -0700
comments: true
categories: 
---

In this post, we compare "Kubernetes operators" and "Kustomize plugins" as different strategies to simplify Kubernetes YAMLs to be managed and/or exposed to service developers, who may be not familiar with Kubernetes.
In the end, we will see that they are not necessarily mutually exclusive: Kustomize plugins are the shift-left, more beginner-friendly versions of Kubernetes operators, but when the need arises, we can easily shift to Kubernetes operators.

<!--more-->

### Background

Let's say we need to deploy a simple web application: TODO: ICNDB

In "Kubernetes operators" stategy (TODO: link), this is done like this

```
$ cat icndb.yml

$ kubectl apply -f icndb.yml
```

In "Kustomize plugins" strategy, the icndb.yml is actually similar: the only difference is the version (not required except to highlight the difference)

```
$ cat icndb.yml

$ kustomize build 

$ kubectl apply -f all.yml
```

### What is the difference?

TODO: Check Evernote "Demo: NewsWebApp operator"

Kustomize plugin vs Controller

* Convert one YAML to multiple k8s-defined YAML
* Declarative configuration
* Follow Unix philosophies

* Client side (laptop) vs. Server side (in k8s)
* Local, easy to unit-test, flexible vs. Lots of lower (talking to mutliple REST APIs), lots of responsibility (testing, update, execute).

We should start with Kustomize plugin.
But when the need of controller is justified (e.g., a service only updated after some custom conditions), you should use it.

### When to use operators

A use case: Solr operator.

Problem with updating Solr STS:

* Solr Pods should NOT be deleted and updated in STS ordering.
* You need to talk to both Kube API and Solr-Cloud API, Solr Prometheus Exporter to determine the order of pods to be deleted and updated.

No matter how you generate YAML (Helm, PCL, Kustomize), the problem is still there.
Solution: Solr operator. Solr Controller talks to both Kube API and Solr-Cloud API to determine the order of pods.

When? Something that is not taken into account by Kubernetes. k8s is a cloud-native OS that provides some baseline behaviors. 


---
layout: post
title: "Design patterns for Container-based distributed systems"
date: 2018-01-14 14:56:56 -0800
comments: true
categories: 
- Docker
- Kubernetes
---

In earlier dates, object-oriented programming (OOP) revolutionized software development by dividing applications into modular components in memory (objects).
Today, the rise of microservice architectures and containerization technologies enable a similar revolution in developing distributed systems and SaaS/PaaS products.
"Containers" is analogus to "objects" in OOP, as a unit of development and deployment in distributed systems.
In [this paper](https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/45406.pdf), the authors argued that just like Design Patterns for Object-Oriented Programming, codified in the famous "Gang of Four" book, some Design Patterns have emerged for Container-based Distributed Systems.
In the same paper, the authors attempted to do something similar, documenting the most common patterns and their usage.

<!--more-->

### General ideas

The container and the container image should be the abstractions for the development of distributed systems.
Similar to what objects did for OOP, thinking in term of containers abstracts away the low-level details of code and allows us to think in higher-level design patterns.
Based on how containers interact with other containers and get deployed into actual VM nodes, the authors divide the patterns in to three main groups:

* Single-container patterns: How to expose interface of application in container (just like object interface).
    * Upward direction: expose application info/metrics such as `/health` endpoint.
    * Downward direction: Formal life cycle agreed between application and management system (similar to Android Activity model).
* Single-node multi-container patterns: Basically, how to design a pod in Kubernetes (pod = group of symbiotic containers)
    * Sidecar pattern:
        * Sidecar containers will extend and enhance the main container.
        * Example: Log forwarding sidecar that collects logs from main container from local disk and stream to a cluster storage system.
    * Ambassador pattern:
        * Ambassador containers will proxy communication to and from the main container.
        * Ambassador simplifies and standardizes the outside world to the main container.
        * Example: Redis proxy ambassador that will discover dependent services for the main container.
    * Adapter pattern:
        * Adapter containers will standardize and normalize the output of the main container.
        * In contrast to ambassador, adapter simplifies and normalizes the main app to outside world.
        * Example: Adapters to ensure all containers have the same monitoring interface to hook to central monitoring system.
* Multi-node patterns
    * Leader election pattern
        * When we have many replicas, but only one of them is active at a time.
    * Work queue pattern
        * One coordinator and many workers distributed to as many nodes for processing.
    * Scatter/Gather pattern
        * Similar to "Work queue" pattern, except one coordinator scatter works to many slaves, then gather/merge works from many slaves.

### References

* [Gang of Four book](https://www.amazon.com/Design-Patterns-Elements-Reusable-Object-Oriented/dp/0201633612/ref=sr_1_3?ie=UTF8&qid=1516232505&sr=8-3&keywords=design+patterns)
* [Original Paper](https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/45406.pdf)
* [Single-node multi-container patterns](http://blog.kubernetes.io/2015/06/the-distributed-system-toolkit-patterns.html)
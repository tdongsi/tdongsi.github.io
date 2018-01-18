---
layout: post
title: "Design patterns for Container-based distributed systems"
date: 2018-01-14 14:56:56 -0800
comments: true
categories: 
- Docker
- Kubernetes
---

In earlier dates, object-oriented programming (OOP) revolutionized software development by dividing applications into modular components as objects and classes.
Today, the rise of microservice architectures and containerization technologies enable a similar revolution in developing distributed systems and SaaS/PaaS products.
"Containers" and "container images" are analogus to "objects" and "classes" in OOP, respectively, as a unit of development and deployment in distributed systems.
In [this paper](https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/45406.pdf), the authors argued that just like Design Patterns for Object-Oriented Programming, codified in the famous ["Gang of Four" book](https://www.amazon.com/Design-Patterns-Elements-Reusable-Object-Oriented/dp/0201633612/ref=sr_1_3?ie=UTF8&qid=1516232505&sr=8-3&keywords=design+patterns), some Design Patterns have emerged for Container-based Distributed Systems.
In the same paper, the authors attempted to do something similar, documenting the most common patterns and their usage.

<!--more-->

### General ideas

The container and the container image should be the abstractions for the development of distributed systems.
Similar to what objects and classes did for OOP, thinking in term of containers abstracts away the low-level details of code and allows us to think in higher-level design patterns.
Based on how containers interact with other containers and get deployed into actual underlying machines, the authors divide the patterns in to three main groups:

* Single-container patterns: How to expose interface of application in container (similar to effective design of object interface).
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
        * Similar to "Work queue" pattern, except one coordinator scatter partial works to many slaves, then gather/merge partial outcomes from those slaves.

### Why multiple containers on single node

The more contentious patterns are probably single-node multi-container patterns, especially the sidecar pattern.
The most common argument is that we can build the functionality of the sidecar into a single main container.
However, recall that we can use similar arguments in OOP to end up with a large class that tries to do many things at once.
There are several benefits to use separate containers:

* Container is the unit of resource allocation and accounting.
  * In the sidecar example above, the log forwarding container is configured to scavenge spare CPU cycles when the web server is not busy.
* Container is the unit of packaging.
  * Two separate teams can work independently on log forwarding and web application.
* Container is the unit of reuse.
  * The log forwarding sidecar image can be paired with other "main" containers.
* Container provides failure containment boundary.
  * If the log forwarding container fails, the application container continues serving.
* Container is the unit of deployment.
  * Each component can be functionally upgraded or rolled back independently.

### References

* [Original Paper](https://static.googleusercontent.com/media/research.google.com/en//pubs/archive/45406.pdf)
* [Single-node multi-container patterns](http://blog.kubernetes.io/2015/06/the-distributed-system-toolkit-patterns.html)
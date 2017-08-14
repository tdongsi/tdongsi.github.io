---
layout: post
title: "Groovy DSL"
date: 2017-08-13 15:18:30 -0700
comments: true
categories: 
- Groovy
- Java
- Jenkins
---

Domain-Specific Language is a mini language for a specific problem and/or in a narrow context.
For example, internally used automation tools usually define some small DSL for configuration and most users understand the context and what DSL offers.

This blog post offers my simplistic view of how an internal DSL is implemented in Groovy via closure delegation.
It shows the progression from standard Java-like implementation to its fluent version to its final DSL form.
This might help undrestanding the inner workings of a DSL such as Jenkins's Pipeline steps.
There are probably more advanced methods/frameworks for creating DSL. 
However, those are not in the scope of this post.

<!--more-->

### Example problem

### Version 1: Java-like standard implementation



### Version 2: Fluent interface with Builder pattern

### Version 3: DSL with Groovy closure

### Reference



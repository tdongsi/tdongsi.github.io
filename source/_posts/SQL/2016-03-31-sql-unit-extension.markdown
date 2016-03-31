---
layout: post
title: "(Pt. 6) SQL unit extension"
date: 2016-04-30 17:49:34 -0700
comments: true
categories: 
- SQL
- Automation
- Testing
- Vertica
- Java
---

Open Closed principle

Design patterns:

* Template Method
* Strategy

Open to extension: new testing needs will arise.
Close to modifications: all the old tests are passing with old test runners.

### Example

Adding parity tests in the same database.

Set theory

Add new JSON.
Use the old code to handle the old POJOs.

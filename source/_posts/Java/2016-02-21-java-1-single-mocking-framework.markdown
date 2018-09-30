---
layout: post
title: "Use one mocking framework ONLY"
date: 2016-02-21 12:20:46 -0800
comments: true
categories: 
- Java
- Testing
- Automation
---

We know that mocking is a critical enabler for unit tests and automated functional tests that don’t require networks and databases and can complete in reasonable time. 
In a large corporate such as Intuit, different business groups tend to adopt different mocking tools/frameworks for their development and test automation needs.
The choice of mocking framework is usually decided by personal preference and experience of few key members of development/automation team.
Mocking tools work by integrating with and replacing critical parts of the Java Class Loader.
It means that having multiple mocking tools in use will lead to those tools contend to replace the class loader in JVM. 
This will lead to complex and unexpected consequences and, as a result, random test failures and unreliable tests.
For example, we might have tests that work fine locally but start failing when running in combination with others (using other mocking tools) because different mocking frameworks take over the class loader in different order or in different ways.

To fix that, we need to standardize and settle early on a single mocking framework for an organization or a project.
Sadly, this is often overlooked before it is too late.

---
layout: post
title: "Use JMockit ONLY"
date: 2016-02-21 12:20:46 -0800
comments: true
categories: 
- Java
- JUnit
- Automation
- JMockit
---

A more general title would be "Use a single mocking framework ONLY".
Personally, it just means that I should defer learning Wiremock's advanced features and learn JMockit (specifically JMockit 1.2x) which is recently adopted at work.

We know that mocking is a critical enabler for unit tests and automated functional tests that don’t require networks and databases and can complete in reasonable time. 
Mocking tools work by integrating with and replacing critical parts of the Java Class Loader.
It means that having multiple mocking tools in use will lead to those tools contend to replace the class loader in JVM. 
This will lead to complex and unexpected consequences and, as a result, random test failures and unreliable tests.
For example, we might have tests that work fine locally but start failing when running in combination with others (using other mocking tools) because different mocking frameworks take over the class loader in different order or in different ways.

To fix that, we need to standardize and settle on a single mocking framework for an organization or a project.

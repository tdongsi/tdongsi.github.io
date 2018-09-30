---
layout: post
title: "Java: unit test performance"
date: 2016-06-06 22:47:42 -0700
comments: true
published: true
categories: 
- Java
- TestNG
- Testing
- Maven
- JUnit
---

According to [this](https://www.youtube.com/watch?v=wEhu57pih5w), the right way of automated testing is that we have lots of unit tests as majority of our overall automated tests, supplemented by a smaller set of functional tests and even fewer sets of integration tests (a.k.a., Test Automation Pyramid). 
However, for that strategy to work, we should pay attention to unit test performance. 
It is not productive for us developers to wait 30+ minutes to run unit tests locally, especially when we have multiple check-ins per day.
In addition, the runtime will get compounded as we add more unit tests.
Here, I list out few commonly observed mistakes to avoid and suggestions that frequently improve Java unit test performance.

<!--more-->

1) Do NOT add loggings/printing to your tests. 
Use TestNG assertions instead of checking screen output.
Remove from the test classes all the `System.out.println` statements (that we might add when we start writing unit tests).
The logs don't matter when we're running in parallel. 
Moreover, it could add 5-10 minutes to the build time, regardless of running in sequential or parallel.

2) Another common mistake is to override the default `System.out` by calling `System.setOut(PrintStream)` and verify by asserting against log statements. 
This tactic is often used to verify expected method invocations, which will subsequently generate some specific log entries.
For such behavior testing, consider using [Jmockit Verifications](https://jmockit.googlecode.com/svn-history/r2056/trunk/www/tutorial/BehaviorBasedTesting.html) instead of depending on output of logs generated.

3) Mock logging and config classes if applicable. 
Otherwise, we might encountered errors like "Exception encountered, logging will be disabled", probably thrown by JMockit.
If there is any static initialization block in the mocked class for logging and configuration purposes, consider using `(stubOutClassInitialization = true)` (see [this](/blog/2016/06/30/java-intermittent-test-failures/)).

4) Choosing the right parallel execution settings can substantially improve the execution time.
However, for parallel test runs, consider splitting big test classes (> 100 tests) that are taking much longer than others. 
As we are running test classes in parallel across multiple JVMs, it is often the case that all JVMs are shut down except for one or two which are running some big test classes. 
Splitting those classes into multiple smaller classes will distribute the load equally across multiple JVMs.

5) Out of all the `maven-surefire` options for running tests in parallel, the one that worked considering JMockit limitations with parallel execution (and our test structure) are as below:

``` xml Maven-surefire options
<parallel>classes</parallel>
<forkCount>${forkCount}</forkCount>
<reuseForks>false</resuseForks>
```

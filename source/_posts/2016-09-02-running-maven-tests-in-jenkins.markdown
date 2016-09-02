---
layout: post
title: "Running Maven tests in Jenkins"
date: 2016-09-03 01:10:36 -0700
comments: true
categories: 
- Maven
- Jenkins
---


``` plain Running
tdongsi$ mvn -f tests/datamart-qe/pom.xml clean test
```

In pom.xml, the test suite file is specified as testng.xml.


http://www.vazzolla.com/2013/03/how-to-select-which-testng-suites-to-run-in-maven-surefire-plugin/
For running a specific test class/test method:
http://stackoverflow.com/questions/1873995/run-a-single-test-method-with-maven



https://wiki.jenkins-ci.org/display/JENKINS/Building+a+software+project
Jenkins set the following variable:
WORKSPACE: The absolute path of the workspace.

I need to set environment variable to simulate Jenkins environment.
In Mac:
For terminal: http://stackoverflow.com/questions/7501678/set-environment-variables-on-mac-os-x-lion
For windowed application: http://stackoverflow.com/questions/135688/setting-environment-variables-in-os-x/588442#588442

Getting environment variable in Java:
https://docs.oracle.com/javase/tutorial/essential/environment/env.html
Map<String, String> env = System.getenv();

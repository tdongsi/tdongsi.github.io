---
layout: post
title: "Jenkins Pipeline Shared Libraries"
date: 2017-02-17 14:38:14 -0800
comments: true
categories: 
- Jenkins
- Git
- Groovy
---

Use Jenkinsfile as Infrastructure as Code.

When you have multiple Pipeline jobs, you often want to share some parts of the Jenkinsfiles between them to keep Jenkinfiles [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself). 
A very common use case is that you have many projects that are built in the similar way.
One way is to use [Workflow plugin](https://github.com/jenkinsci/workflow-cps-global-lib-plugin).

Comprehensive user documentation can be found in [this section](https://jenkins.io/doc/book/pipeline/shared-libraries/) of Jenkins handbook.

However, there is an older way of sharing code is to deploy the Groovy sources to Jenkins.

1) Copy to the folder and restart Jenkins.

2) A more scalable solution is to use Git, exposed by Jenkins.

This older method is no longer mentioned in documentation, as of February 2017.
In fact, you have to look into a [very old commit](https://github.com/jenkinsci/workflow-cps-global-lib-plugin/tree/ce1177278d4cb05ac6b01f723177cc4b2e0aec8d) to find this method briefly mentioned at all.


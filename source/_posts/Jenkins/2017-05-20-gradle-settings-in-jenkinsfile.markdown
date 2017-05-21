---
layout: post
title: "Gradle settings in Jenkinsfile"
date: 2017-05-20 23:27:08 -0700
comments: true
categories: 
- Gradle
- Jenkins
- Maven
- Groovy
---

Nexus authentication.

In Maven, it should be some settings.xml.

In Gralde, the authentication is specified in both build.gradle and graddle.settings file.

In Jenkins, it is not safe to store those in files.

For Gradle, use this. Add link to Jenkins shared libraries.

``` groovy Nexus authentication for Gradle in Jenkinsfile.

```

Based on the https://docs.gradle.org/current/userguide/build_environment.html

If the environment variable name looks like ORG_GRADLE_PROJECT_prop=somevalue, then Gradle will set a prop property on your project object, with the value of somevalue

For Maven, use this.

``` groovy Nexus authentication for Maven in Jenkinsfile.

```

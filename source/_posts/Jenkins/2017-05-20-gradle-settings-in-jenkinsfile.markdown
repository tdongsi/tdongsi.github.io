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
  withCredentials([
    [$class: 'StringBinding', credentialsId: 'nexusUsername', variable: 'ORG_GRADLE_PROJECT_nexusUsername'],
    [$class: 'StringBinding', credentialsId: 'nexusPassword', variable: 'ORG_GRADLE_PROJECT_nexusPassword']
  ]) {
    withEnv([
      'ORG_GRADLE_PROJECT_nexusPublic=https://nexus.example.com/nexus/content/groups/public/',
      'ORG_GRADLE_PROJECT_nexusReleases=https://nexus.example.com/nexus/content/repositories/releases',
      'ORG_GRADLE_PROJECT_nexusSnapshots=https://nexus.example.com/nexus/content/repositories/snapshots'
    ]) {
      sh './gradlew jenkinsBuild'
    }
  }
```

Based on the https://docs.gradle.org/current/userguide/build_environment.html

If the environment variable name looks like ORG_GRADLE_PROJECT_prop=somevalue, then Gradle will set a prop property on your project object, with the value of somevalue

For Maven, use this.

``` groovy Nexus authentication for Maven in Jenkinsfile.
  withCredentials([
    [$class: 'StringBinding', credentialsId: 'nexusUsername', variable: 'nexusUsername'],
    [$class: 'StringBinding', credentialsId: 'nexusPassword', variable: 'nexusPassword']
  ]) {
    withEnv([
      'ORG_GRADLE_PROJECT_nexusPublic=https://nexus.example.com/nexus/content/groups/public/',
      'ORG_GRADLE_PROJECT_nexusReleases=https://nexus.example.com/nexus/content/repositories/releases',
      'ORG_GRADLE_PROJECT_nexusSnapshots=https://nexus.example.com/nexus/content/repositories/snapshots'
    ]) {
      mvnSettingsFile(${env.nexusUsername}, ${env.nexusPassword})
    }
  }
```

### References

* [Gradle build environment](https://docs.gradle.org/current/userguide/build_environment.html)
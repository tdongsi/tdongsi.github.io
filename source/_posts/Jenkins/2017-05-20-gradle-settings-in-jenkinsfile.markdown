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

In this post, we will look into Nexus authentication for Maven and Gradle builds in Jenkins pipelines.

### Maven

Maven builds in corporates usually use private repositories on Nexus, instead of public ones in Maven Central Repository. 
To do that, we usually configure Maven to check Nexus instead of the default, built-in connection to Maven Central.
These configurations is stored in ***~/.m2/settings.xml*** file.

For authentication with Nexus and for deployment, we must provide credentials accordingly. 
We usually add the credentials into our Maven Settings in ***settings.xml*** file.

``` xml Example Credentials in settings.xml
<settings>
  <servers>
    <server>
      <id>nexus</id>
      <username>deployment</username>
      <password>deployment123</password>
    </server>
  </servers>
</settings>
```

In Jenkins, it is not safe to store those in files.

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

### Gradle

In Gralde, the authentication is specified in both build.gradle and graddle.settings file.

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


### References

* [Gradle build environment](https://docs.gradle.org/current/userguide/build_environment.html)
* https://discuss.gradle.org/t/gradle-gradle-properties-file-not-being-read/7574/12 
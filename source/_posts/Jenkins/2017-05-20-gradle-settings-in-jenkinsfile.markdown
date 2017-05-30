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

For authentication with Nexus and for deployment, we must [provide credentials accordingly](https://books.sonatype.com/nexus-book/reference/_adding_credentials_to_your_maven_settings.html). 
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

In Jenkins, it is not safe to store credentials in plain text files.

``` groovy Nexus authentication for Maven in Jenkinsfile.
  withCredentials([
    [$class: 'StringBinding', credentialsId: 'nexusUsername', variable: 'nexusUsername'],
    [$class: 'StringBinding', credentialsId: 'nexusPassword', variable: 'nexusPassword']
  ]) {
    withEnv([
      'nexusPublic=https://nexus.example.com/nexus/content/groups/public/'
    ]) {
      mvnSettingsFile(${env.nexusUsername}, ${env.nexusPassword})
    }
  }
```

TODO: explain withCredentials and credentialsId.

### Gradle

In Gradle, Nexus authentication can be specified in both `build.gradle` and `gradle.properties` file.

``` groovy Example build.gradle
    repositories {
        maven {
            credentials {
                username nexusUsername
                password nexusPassword
            }
            url { nexusPublic }
        }
    }
```

``` properties Example gradle.properties
nexusUsername=myUsername
nexusPassword=password123
nexusPublic=https://nexus.example.com/nexus/content/groups/public/
```

The default location of the `gradle.properties` file is `~/.gradle`. 
This is due to the environment variable `GRADLE_USER_HOME` usually set to `~/.gradle`.
For custom location of `~/.gradle`, ensure that the variable `GRADLE_USER_HOME` set accordingly.

However, similar to Maven, for Jenkins pipeline automation, it is not safe to store credentials in plain text file `gradle.properties`.
For that purpose, you should use the following Groovy code:

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

In Gradle, the solution is made easier because Gradle respects properies set through environment variales.
Based on [its doc](https://docs.gradle.org/current/userguide/build_environment.html), if the environment variable name looks like ***ORG_GRADLE_PROJECT_prop=somevalue***, then Gradle will set a `prop` property on your project object, with the value of `somevalue`.

TODO: shared libraries.

### References

* [Gradle build environment](https://docs.gradle.org/current/userguide/build_environment.html)
* [Stackoverflow dicussion](https://stackoverflow.com/questions/12749225/where-to-put-gradle-configuration-i-e-credentials-that-should-not-be-committe): for older versions of Gradle.
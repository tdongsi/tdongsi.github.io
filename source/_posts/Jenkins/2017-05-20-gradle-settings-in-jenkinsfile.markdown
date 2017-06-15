---
layout: post
title: "Maven and Gradle builds in Jenkinsfile"
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
These configurations is stored in *~/.m2/settings.xml* file.

For authentication with Nexus and for deployment, we must [provide credentials accordingly](https://books.sonatype.com/nexus-book/reference/_adding_credentials_to_your_maven_settings.html). 
We usually add the credentials into our Maven Settings in *settings.xml* file.

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

However, for automated build and deployment in Jenkins pipelines, it is not safe to store credentials in plain text files. 
Instead, one should store Nexus credentials as [secrets in Jenkins](https://wiki.jenkins-ci.org/display/JENKINS/Credentials+Plugin) and pass them into Jenkinsfile using their IDs (`credentialsId`). 
See [this article](https://support.cloudbees.com/hc/en-us/articles/203802500-Injecting-Secrets-into-Jenkins-Build-Jobs) for the full picture of related plugins used for storing and passing secrets in Jenkins.

``` groovy Nexus authentication for Maven in Jenkinsfile.
  withCredentials([
    [$class: 'StringBinding', credentialsId: 'nexusUsername', variable: 'nexusUsername'],
    [$class: 'StringBinding', credentialsId: 'nexusPassword', variable: 'nexusPassword']
  ]) {
    withEnv([
      'nexusPublic=https://nexus.example.com/nexus/content/groups/public/'
    ]) {
      mvnSettingsFile(${env.nexusUsername}, ${env.nexusPassword})
      sh 'mvn -s settings.xml clean build'
    }
  }
```

The [step `withCredentials`](https://jenkins.io/doc/pipeline/steps/credentials-binding/) will not only provide a secure way of injecting secrets (e.g., Nexus credentials) into Jenkins pipeline, but also scrub away such sensitive information if we happen to print them out in log files.
`mvnSettingsFile` is my Groovy function that generates the `settings.xml` based on the pre-defined format and provided Nexus credentials.

#### Maven 3.0

Since **Maven 3.0**, the above problem is made much easier since environment variables can be referred inside `settings.xml` file by using special expression `${env.VAR_NAME}`, based on [this doc](https://maven.apache.org/settings.html).
Nexus authentication for Maven 3.0 in Jenkins pipeline can be done as follows:

``` xml settings.xml in Maven 3.0
<settings>
  <servers>
    <server>
      <id>nexus</id>
      <username>${env.MVN_SETTINGS_nexusUsername}</username>
      <password>${env.MVN_SETTINGS_nexusPassword}</password>
    </server>
  </servers>
</settings>
```

``` groovy Passing Nexus credentials for Maven 3.0 in Jenkinsfile
  withCredentials([
    [$class: 'StringBinding', credentialsId: 'nexusUsername', variable: 'MVN_SETTINGS_nexusUsername'],
    [$class: 'StringBinding', credentialsId: 'nexusPassword', variable: 'MVN_SETTINGS_nexusPassword']
  ]) {
    withEnv([
      'nexusPublic=https://nexus.example.com/nexus/content/groups/public/'
    ]) {
      sh 'mvn -s settings.xml clean build'
    }
  }
```

However, note that it is still tricky even in Maven 3.0 since this is not always applicable, as noted in [the same doc](https://maven.apache.org/settings.html).

{% blockquote %}
Note that properties defined in profiles within the settings.xml cannot be used for interpolation.
{% endblockquote %}

### Gradle

In Gradle, Nexus authentication can be specified in both `build.gradle` and `gradle.properties` file, where `build.gradle` should be checked into VCS (e.g., git) while `gradle.properties` contains sensitive credentials information.

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
For custom location of `gradle.properties` (i.e., other than `~/.gradle`), ensure that the variable `GRADLE_USER_HOME` is set accordingly.

However, similar to Maven, for Jenkins pipeline automation, it is not safe to store credentials in plain text file `gradle.properties`, no matter how "hidden" its location is.
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

Note that, in Gradle, the solution is much simpler because Gradle respects properies set through environment variales.
Based on [its doc](https://docs.gradle.org/current/userguide/build_environment.html), if the environment variable name looks like ***ORG_GRADLE_PROJECT_prop=somevalue***, then Gradle will set a `prop` property on your project object, with the value of `somevalue`. 
Therefore, in `withCredentials` step, we specifically bind the secrets `nexusUsername` and `nexusPassword` to the environment variables *ORG_GRADLE_PROJECT_nexusUsername* and *ORG_GRADLE_PROJECT_nexusPassword* and not some arbitrary variable names. 
These environment variables should match the ones used in `builde.gradle` and, in the following Closure, we simply call the standard Gradle wrapper command `./gradlew <target>`.
Compared with Maven solution in the last section, there is no intermediate step to generate `settings.xml` based on the provided secrets. 

### More Tips

If Maven/Gradle build is used in multiple repositories across organization, it is recommended to move the above Groovy code into shared Jenkins library, as shown in [last post](/blog/2017/03/17/jenkins-pipeline-shared-libraries/).
For example, the Gradle builds can be simplified by defining `useNexus` step (see [here](https://jenkins.io/doc/book/pipeline/shared-libraries/#defining-steps)) and adding it into the [shared library *workflow-lib*](/blog/2017/03/17/jenkins-pipeline-shared-libraries/).

``` groovy vars/useNexus.groovy
def call(Closure body) {
  withCredentials([
    [$class: 'StringBinding', credentialsId: 'nexusUsername', variable: 'ORG_GRADLE_PROJECT_nexusUsername'],
    [$class: 'StringBinding', credentialsId: 'nexusPassword', variable: 'ORG_GRADLE_PROJECT_nexusPassword']
  ]) {
    withEnv([
      'ORG_GRADLE_PROJECT_nexusPublic=https://nexus.example.com/nexus/content/groups/public/',
      'ORG_GRADLE_PROJECT_nexusReleases=https://nexus.example.com/nexus/content/repositories/releases',
      'ORG_GRADLE_PROJECT_nexusSnapshots=https://nexus.example.com/nexus/content/repositories/snapshots'
    ]) {
      body()
    }
  }
}
```

After that, all the Gradle builds with Nexus authentication in Jenkinsfile will now be reduced to simply this:

``` groovy Simplified Nexus authentication for Gradle in Jenkinsfile.
useNexus {
  sh './gradlew jenkinsBuild'
}
```

As shown above, it will reduce lots of redundant codes for Gradle builds, repeated again and again in Jenkinsfiles across multiple repositories in an organizaiton.

### References

* [Secrets in Jenkins build jobs](https://support.cloudbees.com/hc/en-us/articles/203802500-Injecting-Secrets-into-Jenkins-Build-Jobs)
* [Gradle build environment](https://docs.gradle.org/current/userguide/build_environment.html)
* [Stackoverflow dicussion](https://stackoverflow.com/questions/12749225/where-to-put-gradle-configuration-i-e-credentials-that-should-not-be-committe): for older versions of Gradle.

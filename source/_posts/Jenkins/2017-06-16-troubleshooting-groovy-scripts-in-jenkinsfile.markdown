---
layout: post
title: "Troubleshooting Groovy code in Jenkinsfile"
date: 2017-06-16 23:52:44 -0700
comments: true
categories: 
- Groovy
- Jenkins
---

In this post, we look into some troubleshooting tips when [using independent Groovy scripts in Jenkins pipeline](/blog/2017/04/18/groovy-code-in-jenkins-pipeline/).

### Named parameters not supported

Named parameters in Groovy apparently is not supported in Jenkinsfile:

``` groovy Named parameters
// This does NOT work
def bodyText = code.getPrBody(githubUsername: env.GITHUB_USERNAME, githubToken: env.GITHUB_PASSWORD, repo: 'Groovy4Jenkins', id: env.CHANGE_ID)

// This works
def bodyText = code.getPrBody(env.GITHUB_USERNAME, env.GITHUB_PASSWORD, 'Groovy4Jenkins', env.CHANGE_ID)
```

We get the following error message when using named parameters:

``` plain Error message
java.lang.NoSuchMethodError: No such DSL method 'getPrBody' found among steps [archive, bat, build, catchError, checkout, deleteDir, dir, echo, emailext, emailextrecipients, error, fileExists, findFiles
...
```

### Cannot load a Groovy script in Declarative Pipeline

``` groovy Loading Groovy script
            steps {
               checkout scm
               withCredentials([
                 [$class: 'StringBinding', credentialsId: 'nexusUserName', variable: 'nexusUserName'],
                 [$class: 'StringBinding', credentialsId: 'nexusPassword', variable: 'nexusPassword']
               ]) {
                   script {
                       myScript = load 'jenkins/xml.groovy'
                       String myPath = myScript.transformXml(settingsFile, env.nexusUserName, env.nexusPassword)
                       sh "mvn -B -s ${myPath} clean compile"
                   
                       sh "rm ${myPath}"
                   }
               }
           }
```

``` plain Error in Jenkins log
java.lang.NoSuchMethodError: No such DSL method '$' found among steps 
[archive, bat, build, catchError, checkout, deleteDir, dir, dockerFingerprintFrom, ...
```

### Serialzation errors

There is also some known [issue about JsonSlurper](https://issues.jenkins-ci.org/browse/JENKINS-35140).

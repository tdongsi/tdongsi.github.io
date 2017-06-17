---
layout: post
title: "Troubleshooting Groovy code in Jenkinsfile"
date: 2017-06-16 23:52:44 -0700
comments: true
categories: 
- Groovy
- Jenkins
---

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

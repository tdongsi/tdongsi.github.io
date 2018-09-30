---
layout: post
title: "Advanced Jenkinsfile cookbook"
date: 2017-07-19 14:23:01 -0700
comments: true
categories: 
- Groovy
- Jenkins
---

This post details some of the more advanced Jenkins pipelines using Jenkinsfile.

<!--more-->

### Nexus authentication in Maven

More detailed discussion is in [here](/blog/2017/06/17/groovy-in-jenkinsfile/).

``` groovy Jenkinsfile
def myScript

pipeline {
   agent { node { label 'test-agent' } }
   stages {
       stage("compile") {
           steps {
               checkout scm
               withCredentials([
                 [$class: 'StringBinding', credentialsId: 'nexusUsername', variable: 'nexusUsername'],
                 [$class: 'StringBinding', credentialsId: 'nexusPassword', variable: 'nexusPassword']
               ]) {
                   script {
                       myScript = load 'jenkins/xml.groovy'
                       def xmlTemplate = readFile( 'jenkins/settings.xml' )
                       String xmlFile = myScript.transformXml(xmlTemplate, env.nexusUsername, env.nexusPassword)
                       
                       String myPath = 'temp.xml'
                       writeFile file: myPath, text: xmlFile
                       
                       sh "mvn -B clean compile -s ${myPath}"
                   
                       sh "rm ${myPath}"
                   }
               }
           }
           post {
           failure {
               echo "Sending email for compile failed (TBD)"
            }
           }
       }
   }
}

```

``` groovy xml.groovy
import groovy.xml.StreamingMarkupBuilder
import groovy.xml.XmlUtil

@NonCPS
def transformXml(String xmlContent, String username, String password) {
  def xml = new XmlSlurper(false, false).parseText(xmlContent)
  
  echo 'Start tranforming XML'
  xml.servers.server.each { node ->
    node.username = username
    node.password = password
  }
  
  def outWriter = new StringWriter()
  XmlUtil.serialize( xml, outWriter )
  return outWriter.toString()
}

return this
```

### Running test suite in parallel

It is possible to take a Maven/JUnit-based test suite that takes too long to run on a single node and parallelize the test execution across multiple nodes instead.
The Parallel Test Executor Plugin is exactly for that purpose.

``` groovy Jenkinsfile
node('remote') {
  git 'https://github.com/jenkinsci/parallel-test-executor-plugin-sample.git'
  stash name: 'sources', includes: 'pom.xml,src/'
}
def splits = splitTests count(2)
def branches = [:]
for (int i = 0; i < splits.size(); i++) {
  def index = i // fresh variable per iteration; i will be mutated
  branches["split${i}"] = {
    node('remote') {
      deleteDir()
      unstash 'sources'
      def exclusions = splits.get(index);
      writeFile file: 'exclusions.txt', text: exclusions.join("\n")
      sh "${tool 'M3'}/bin/mvn -B -Dmaven.test.failure.ignore test"
      junit 'target/surefire-reports/*.xml'
    }
  }
}
parallel branches
```

Note that, this is **different** from modiyfing test harness (e.g., JUnit, TestNG) to parallelize the test execution on a single node.
It could be time-consuming and risk destabalizing the tests while the chance of success is usually small.

More details can be found in the following links:

* [TUTORIAL](https://github.com/jenkinsci/pipeline-plugin/blob/master/TUTORIAL.md)
* [More in Blog post](https://jenkins.io/blog/2016/06/16/parallel-test-executor-plugin/)
* [Plugin page](https://wiki.jenkins-ci.org/display/JENKINS/Parallel+Test+Executor+Plugin): `splitTests` defined by this plugin.

---
layout: post
title: "Groovy in Jenkinsfile"
date: 2017-06-17 12:08:15 -0700
comments: true
categories: 
- Groovy
- Jenkins
---

Groovy is supported in Jenkinsfile for quick scripting. 
However, lots of features in the Groovy language is not supported and simple works in Groovy can be really tricky in Jenkinsfile.

<!--more-->

### Different ways to process XML file

In summary, if it is possible, use another script language (e.g., Python) for **file manipulation** in Jenkinsfile. 
It is time consuming to navigate all tricky stuffs of Groovy implementaiton in Jenkins:

* In-process Script Approval: you have to approve every single class and method *one by one*.
* Some features of Groovy is not supported and it takes time to figure out what is not supported and how to work around. When in doubt, use `@NonCPS`.

#### Groovy method in Jenkinsfile

``` groovy Jenkinsfile
import groovy.xml.StreamingMarkupBuilder
import groovy.xml.XmlUtil

def settingsFile = 'temp.xml'

@NonCPS
def xmlTransform(txt, username, password) {
    
    def xmlRoot = new XmlSlurper(false, false).parseText(txt)
    echo 'Start tranforming XML'
    xmlRoot.servers.server.each { node ->
       node.username = username
       node.password = password
    }

    // TRICKY: FileWriter does NOT work
    def outWriter = new StringWriter()
    XmlUtil.serialize( xmlRoot, outWriter )
    return outWriter.toString()
}

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
                       def xmlTemplate = readFile( 'jenkins/settings.xml' )
                       def xmlFile = xmlTransform(xmlTemplate, env.nexusUsername, env.nexusPassword)
                       writeFile file: settingsFile, text: xmlFile
                       
                       sh "mvn -B -s ${settingsFile} clean compile"
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

Some notes:

* `import` statements must be at the top, right after the shebang and before anything else.
* The Groovy methods must be annotated with `@NonCPS` or Jenkins will report the error "java.io.NotSerializableException".
* The Groovy methods can not be defined inside a `step` block. It must be defined at the top.
* `@NonCPS` is required since the Groovy method uses several non-serializble objects. 

#### Groovy method in separate script

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
                       def mCommand = "cat >${myPath} <<EOF"
                       mCommand += "\n${xmlFile}\nEOF"
                       sh mCommand
                       
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

#### Groovy method in shared library

The above Nexus authentication code is likely repeated across multiple Maven builds.
Therefore, it is worth converting it into a DSL into a Shared Library in Jenkins.
The DSL takes two parameters:

* templateFile: settings.xml template with Nexus credentials info redacted.
* command: Maven command with settings file NOT specified (i.e., NO "-s" option in the command).

The example usage is as follows:

``` groovy Jenkinsfile
pipeline {
   agent { node { label 'test-agent' } }
   stages {
       stage("compile") {
           steps {
               checkout scm
               script {
                    withNexusMaven {
                        templateFile = 'jenkins/settings.xml'
                        command = "mvn -B clean compile"
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

The Jenksinfile is much cleaner since most of implementation details have been moved inside the DSL:

``` groovy withNexusMaven.groovy
#!groovy
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

def call(Closure body) {

    def config = [:]
    if (body != null) {
        body.resolveStrategy = Closure.DELEGATE_FIRST
        body.delegate = config
        body()
    }

    def templateFile = config.templateFile ?: '/home/data/settings.xml'
    def command = config.command ?: "mvn -B clean compile"

    withCredentials([
        [$class: 'StringBinding', credentialsId: 'nexusUsername', variable: 'nexusUsername'],
        [$class: 'StringBinding', credentialsId: 'nexusPassword', variable: 'nexusPassword']
    ]) {
        def xmlTemplate = readFile templateFile
        String xmlFile = transformXml(xmlTemplate, env.nexusUsername, env.nexusPassword)

        String tempFile = 'temp.xml'
        writeFile file: tempFile, text: xmlFile

        sh "${command} -s ${tempFile}"

        // Clean up
        sh "rm ${tempFile}"
    }
}
```

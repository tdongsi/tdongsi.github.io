---
layout: post
title: "Advanced Jenkinsfile cookbook"
date: 2017-06-19 14:23:01 -0700
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

When you run this Pipeline for the first time, it will check out a project and run all of its tests in sequence.
The second and subsequent times you run it, the `splitTests` task will partition your tests into two sets of roughly equal runtime.
The rest of the Pipeline then runs these in parallel — so if you look at **trend** (in the **Build History** widget) you will see the second and subsequent builds taking roughly half the time of the first.
If you only have the one agent configured with its two executors, this won't save as much time, but you may have multiple agents on different hardware matching the same label expression.

This script is more complex than the previous ones so it bears some examination.
You start by grabbing an agent, checking out sources, and making a copy of them using the `stash` step:

```groovy
stash name: 'sources', includes: 'pom.xml,src/'
```

Later, you `unstash` these same files back into **other** workspaces.
You could have just run `git` anew in each agent's workspace, but this would result in duplicated changelog entries, as well as contacting the Git server twice.
* A Pipeline build is permitted to run as many SCM checkouts as it needs to, which is useful for projects working with multiple repositories, but not what we want here.
* More importantly, if anyone pushes a new Git commit at  the wrong time, you might be testing different sources in some branches - which is prevented when you do the checkout just once and distribute sources to agents yourself.

The command `splitTests` returns a list of lists of strings.
From each (list) entry, you construct one branch to run; the label (map key) is akin to a thread name, and will appear in the build log.
The Maven project is set up to expect a file `exclusions.txt` at its root, and it will run all tests _not_ mentioned there, which we set up via the `writeFile` step.
When you run the `parallel` step, each branch is started at the same time, and the overall step completes when all the branches finish: “fork & join”.

There are several new ideas at work here:
* A single Pipeline build allocates several executors, potentially on different agents, at the same time.
You can see these starting and finishing in the Jenkins executor widget on the main screen.

* Each call to `node` gets its own workspace.
This kind of flexibility is impossible in a freestyle project, each build of which is tied to exactly one workspace.The Parallel Test Executor plugin works around that for its freestyle build step by triggering multiple builds of the project, making the history hard to follow.

Do not use `env` in this case:

```groovy
env.PATH = "${mvnHome}/bin:${env.PATH}"
```

because environment variable overrides are  limited to being global to a pipeline run, not local to the current thread (and thus agent).
You could, however, use the `withEnv` step as noted above.

You may also have noticed that you are running `JUnitResultArchiver` several times, something that is not possible in a freestyle project.
The test results recorded in the build are cumulative.

When you view the log for a build with multiple branches, the output from each will be intermixed.
It can be useful to click on the _Pipeline Steps_ link on the build’s sidebar.
This will display a tree-table view of all the steps run so far in the build, grouped by logical block, for example `parallel` branch.
You can click on individual steps and get more details, such as the log output for that step in isolation, the workspace associated with a `node` step, and so on.

#### Reference

* [TUTORIAL](https://github.com/jenkinsci/pipeline-plugin/blob/master/TUTORIAL.md)
* [More in Blog post](https://jenkins.io/blog/2016/06/16/parallel-test-executor-plugin/)
* [Plugin page](https://wiki.jenkins-ci.org/display/JENKINS/Parallel+Test+Executor+Plugin): `splitTests` defined by this plugin.

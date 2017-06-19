---
layout: post
title: "Groovy Script in Jenkins pipeline"
date: 2017-04-18 17:07:44 -0700
comments: true
published: true
categories: 
- Groovy
- Jenkins
---

In this post, we look into loading and reusing independent Groovy scripts for more modular and testable Jenkins pipeline.

### Basic example of Loading Groovy scripts

``` plain script example.groovy
def example1() {
  println 'Hello from example1'
}

def example2() {
  println 'Hello from example2'
}

return this
```

The `example.groovy` script defines `example1` and `example2` functions before ending with `return this`. 
Note that `return this` is definitely required and one common mistake is to forget ending the Groovy script with it.

``` groovy Jenkinsfile
def code

node('java-agent') {
  stage('Checkout') {
    checkout scm
  }
  
  stage('Load') {
    code = load 'example.groovy'
  }
  
  stage('Execute') {
    code.example1()
  }
}

code.example2()
```

In Jenkinsfile, simply use [`load` step](https://jenkins.io/doc/pipeline/steps/workflow-cps/#load-evaluate-a-groovy-source-file-into-the-pipeline-script) to load the Groovy script.
After the Groovy script is loaded, the functions insides can be used where it can be referenced, as shown above.

### Demo: Processing Github JSON from Groovy

In this demo, we first show how to process JSON response from Github API in Groovy.

``` groovy Processing JSON from Github
String username = System.getenv('GITHUB_USERNAME')
String password = System.getenv('GITHUB_PASSWORD')

String GITHUB_API = 'https://api.github.com/repos'
String repo = 'groovy'
String PR_ID = '2' // Pull request ID

String url = "${GITHUB_API}/${username}/${repo}/pulls/${PR_ID}"
println "Querying ${url}"
def text = url.toURL().getText(requestProperties: ['Authorization': "token ${password}"])
def json = new JsonSlurper().parseText(text)
def bodyText = json.body

// Check if Pull Request body has certain text
if ( bodyText.find('Safari') ) {
    println 'Found Safari user'
}
```

The equivalent bash command for retrieving JSON response from Github API is as follows:

``` plain Equivalent bash command
// Groovy formatted string
String cmd = "curl -s -H \"Authorization: token ${password}\" ${url}"

// Example
String example = 'curl -s -H "Authorization: token XXX" https://api.github.com/repos/tdongsi/groovy/pulls/2'
```

### Processing Github JSON from Jenkinsfile

Continuing the demo from the last section, we now put the Groovy code into a callable function in a script called "github.groovy". 
Then, in our Jenkinsfile, we proceed to load the script and use the function to process JSON response from Github API.

``` groovy github.groovy
import groovy.json.JsonSlurper

def getPrBody(String githubUsername, String githubToken, String repo, String id) {
  String GITHUB_API = 'https://api.github.com/repos'

  String url = "${GITHUB_API}/${githubUsername}/${repo}/pulls/${id}"
  println "Querying ${url}"
  def text = url.toURL().getText(requestProperties: ['Authorization': "token ${githubToken}"])
  def json = new JsonSlurper().parseText(text)
  def bodyText = json.body
  
  return bodyText
}

return this
```

``` groovy Jenkinsfile
def code

node('java-agent') {
  stage('Checkout') {
    checkout scm
  }
  
  stage('Load') {
    code = load 'github.groovy'
  }
  
  stage('Execute') {
    withCredentials([
      [$class: 'UsernamePasswordMultiBinding', credentialsId: 'githubCredentials', 
      passwordVariable: 'GITHUB_PASSWORD', usernameVariable: 'GITHUB_USERNAME']
    ]) {

      def bodyText = code.getPrBody(env.GITHUB_USERNAME, env.GITHUB_PASSWORD, 
                                    'Groovy4Jenkins', env.CHANGE_ID)
      println bodyText

    }
  }
}
```

### More discussion

TODO: For DSL

``` groovy Boiler plate code for DSL
def call(Closure body) {
  def config = [:]

  if (body != null) {
    body.resolveStrategy = Closure.DELEGATE_FIRST
    body.delegate = config
    body()
  }

  ...

}
```

### Troubleshooting tips

When loading and running Groovy scripts, you might find yourself running to RejectedAccessException errors.
In those cases, usually it can be resolved by manually approving some method signatures in **Jenkins > Manage Jenkins > In-process Script Approval** page. 
Adminstrators privilege is required for doing so.

More troubleshooting information is listed in this [blog post](/blog/2017/06/16/troubleshooting-groovy-scripts-in-jenkinsfile/).

### Reference

* [JenkinsCI example](https://github.com/jenkinsci/pipeline-examples/tree/master/pipeline-examples/load-from-file)
* [`load` step](https://jenkins.io/doc/pipeline/steps/workflow-cps/#load-evaluate-a-groovy-source-file-into-the-pipeline-script)
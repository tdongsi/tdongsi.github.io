---
layout: post
title: "Groovy code in Jenkins pipeline"
date: 2017-04-18 17:07:44 -0700
comments: true
categories: 
- Groovy
- Jenkins
---




``` plain Jenkinsfile
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

``` plain script example.groovy
def example1() {
  println 'Hello from example1'
}

def example2() {
  println 'Hello from example2'
}

return this
```

The `example.groovy` script defines `example1` and `example2` functions before ending with return this.

### Processing Github JSON from Groovy

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

The equivalent bash command is

``` plain Equivalent bash command
// Groovy formatted string
String cmd = "curl -s -H \"Authorization: token ${password}\" ${url}"

// Example
String example = 'curl -s -H "Authorization: token XXX" https://api.github.com/repos/tdongsi/groovy/pulls/2'
```

### Processing Github JSON from Jenkinsfile

```
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

A little bit about In-process Script Approval

``` plain Jenkinsfile
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
      [$class: 'UsernamePasswordMultiBinding', credentialsId: 'githubCredentials', passwordVariable: 'GITHUB_PASSWORD', usernameVariable: 'GITHUB_USERNAME']
    ]) {
      code.test()

      def bodyText = code.getPrBody(env.GITHUB_USERNAME, env.GITHUB_PASSWORD, 'Groovy4Jenkins', env.CHANGE_ID)
      println bodyText

    }
  }
}
```


---
layout: post
title: "Jenkins Pipeline unit testing"
date: 2018-06-07 22:33:46 -0700
comments: true
categories: 
- Jenkins
- Java
- Groovy
- Gradle
- Testing
---

This blog post explains how to do unit testing for Jenkins shared library with PipelineUnitTests.

https://jenkins.io/doc/book/pipeline/development/#unit-test

<!--more-->

### Jenkins shared library

```groovy buildWrapper.groovy
def call(Closure body) {
  def config = [:]

  if (body != null) {
    body.resolveStrategy = Closure.DELEGATE_FIRST
    body.delegate = config
    body()
  }

  def settings = config.settings ?: "settings.xml"

  node('java-agent') {
    stage('Checkout') {
      checkout scm
    }

    stage('Main') {
      // Test Python setup
      sh(script: 'python -c "import requests"', returnStatus: true)
      // Test Docker setup
      sh 'docker version'
    }

    stage('Post') {
      // Print info of standard tools
      sh 'ls -al'
      sh 'java -version'
      sh "mvn -s $settings -version"
      sh 'python -V'
    }
  }
}
```

In Jenkinsfile, you can call it as follows to use default parameters:

```groovy
buildWrapper {
}
```

or you can set the parameters in the wrapper's body:

```groovy
buildWrapper {
  settings = "dummy.xml"
}
```

You can test that using PipelineUnitTests.

Need to mock some function and variables

You need to printCallStack().

Create a text file. The file name matches the class name.

`testNonRegression("default")` to run regression tests. 

Show diff in IntelliJ.

### Other usage

You can also use PipelineUnitTests to test Jenkinsfile.
In most cases, testing Jenkinsfile will be similar to testing Groovy files in `vars` folder, as explained above, since they are quite similar.

```groovy Example Jenkinsfile
node() {
  stage('Checkout') {
    checkout scm
    sh 'git clean -xdf'
  }

  stage('Build and test') {
    sh './gradlew build'
    junit 'build/test-results/test/*.xml'
  }
}
```

The process is very similar: you need to mock out some global variables and functions corresponding to Jenkins pipeline steps.
You will need to `printCallStack` to obtain the expected output and save it into some text file.
Then, you can use `testNonRegression` for automated verification of no-regression in Jenkinsfile.

However, unlike Groovy files in `vars` folder, Jenkinsfiles are regularly updated and usually NOT depended on by any other codes.
Therefore, automated tests for Jenkinsfile are not very common because of the cost/effort required.

### References

* [JenkinsPipelineUnit](https://github.com/jenkinsci/JenkinsPipelineUnit)
* [The talk at Jenkins World 17](https://www.youtube.com/watch?v=RmrpUtbVR7o)
* [Example](https://github.com/tdongsi/jenkins-steps-override)

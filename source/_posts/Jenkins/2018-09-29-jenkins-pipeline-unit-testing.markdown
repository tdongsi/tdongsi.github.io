---
layout: post
title: "Jenkins Pipeline unit testing"
date: 2018-06-07 22:33:46 -0700
comments: true
categories: 
- Jenkins
- Groovy
- Testing
---

[Jenkins shared library](https://jenkins.io/doc/book/pipeline/shared-libraries/) is a powerful way for sharing Groovy code between multiple Jenkins pipelines.
However, when many Jenkins pipelines, including mission-critical deployment pipelines, depend on such shared libraries, automated testing becomes necessary to prevent regressions whenever new changes are introduced into shared librariers.
Despite its drawbacks, the third-party [Pipeline Unit Testing framework](https://github.com/jenkinsci/JenkinsPipelineUnit) satisfies some of automated testing needs.
It would allow you to do mock execution of pipeline steps and checking for expected behaviors before actually running in Jenkins.
However, documentation for this third-party framework is severely lacking (mentioned briefly [here](https://jenkins.io/doc/book/pipeline/development/#unit-test)) and it is one of many reasons that unit testing for Jenkins shared libraries is usually an after-thought, instead of being integrated early.
In this blog post, we will see how to do unit testing for Jenkins shared library with the Pipeline Unit Testing framework.

<!--more-->

### Testing Jenkins shared library 

#### Example Groovy file

For this tutorial, we look at the following Groovy build wrapper as the example under test:

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

After the shared library is set up properly, you can call the above Groovy build wrapper in Jenkinsfile as follows to use default parameters:

```groovy Jenkinsfile for first use case 
buildWrapper {
}
```

or you can set the parameters in the wrapper's body as follows:

```groovy Jenkinsfile for second use case
buildWrapper {
  settings = "dummy.xml"
}
```

In the next section, we will look into automated testing of both use cases using JenkinsPipelineUnit.

#### Using JenkinsPipelineUnit (WIP)

To use JenkinsPipelineUnit, it is recommended to set up IntelliJ following [this tutorial](/blog/2018/02/09/intellij-setup-for-jenkins-shared-library-development/).

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

However, unlike Groovy files in `vars` folder, Jenkinsfiles are regularly updated and usually NOT used by any other codes.
Therefore, automated tests for Jenkinsfile are not very common because of the cost/effort required.

### References

* [JenkinsPipelineUnit](https://github.com/jenkinsci/JenkinsPipelineUnit)
* [The talk at Jenkins World 17](https://www.youtube.com/watch?v=RmrpUtbVR7o)
* [Example](https://github.com/tdongsi/jenkins-steps-override)

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

#### Using JenkinsPipelineUnit

To use JenkinsPipelineUnit, it is recommended to set up IntelliJ following [this tutorial](/blog/2018/02/09/intellij-setup-for-jenkins-shared-library-development/).

To test the above `buildWrapper.groovy` using the Jenkins Pipeline Unit, you can start with a unit test for the second use case as follows:

``` groovy
  /**
   * Represent the call:
   *     buildWrapper {
   *       settings = "dummy.xml"
   *     }
   *
   * @throws Exception
   */
  @Test
  public void configured() throws Exception {
    def script = loadScript('vars/buildWrapper.groovy')
    script.call({
      settings = "dummy.xml"
    })

    printCallStack()
  }
```

Unfortunately, when executing that unit test, it is very likely that you will get various errors that are not well-explained by JenkinsPipelineUnit documentation.

``` plain Stack trace
groovy.lang.MissingPropertyException: No such property: scm for class: demoWrapper

	at org.codehaus.groovy.runtime.ScriptBytecodeAdapter.unwrap(ScriptBytecodeAdapter.java:66)
	at org.codehaus.groovy.runtime.callsite.PogoGetPropertySite.getProperty(PogoGetPropertySite.java:51)
	at org.codehaus.groovy.runtime.callsite.AbstractCallSite.callGroovyObjectGetProperty(AbstractCallSite.java:310)
	at demoWrapper$_call_closure1$_closure2.doCall(demoWrapper.groovy:19)
```

The short explanation is that the mock execution environment is not properly set up.
First, we need to call `setUp()` from the base class BaseRegressionTest of JenkinsPipelineUnit to set up the mock execution environment.
In addition, since most Groovy scripts will have this statement `checkout scm`, we need to [mock the Jenkins global variable](https://github.com/jenkinsci/JenkinsPipelineUnit#mock-jenkins-variables) `scm`, which represents the SCM state (e.g., Git commit) associated with the current Jenkinsfile.
The most simple way to mock it is to set it to empty state as follows:

``` groovy Mocking Jenkins variable scm
binding.setVariable('scm', [:])
```

We can also set it to a more meaningful value such as a Git branch as follows:

``` groovy Mocking Jenkins variable scm
    binding.setVariable('scm', [
        $class: 'GitSCM',
        branches: [[name: 'master']],
        doGenerateSubmoduleConfigruations: false,
        extensions: [],
        submoduleCfg: [],
        userRemoteConfigs: [[url: "/var/git-repo"]]
    ])
```

However, an empty `scm` will usually suffice.
Besides Jenkins variables, we can also [register different Jenkins steps/commands](https://github.com/jenkinsci/JenkinsPipelineUnit#mock-jenkins-commands) as follows:

``` groovy Mocking Jenkins step library
helper.registerAllowedMethod('library', [String.class], null)
```

After going through the setup steps above, you should have the following setup method like this:

``` groovy Minimum setup method
import com.lesfurets.jenkins.unit.BaseRegressionTest

class DemoTest extends BaseRegressionTest {

  @Override
  @Before
  public void setUp() throws Exception {
    super.setUp();
    binding.setVariable('scm', [:])
    helper.registerAllowedMethod('library', [String.class], null)
  }
...
}
```

Rerunning the above unit test will show the full stack of execution:

``` plain
   buildWrapper.call(groovy.lang.Closure)
      buildWrapper.node(java-agent, groovy.lang.Closure)
         buildWrapper.stage(Checkout, groovy.lang.Closure)
            buildWrapper.checkout({})
         buildWrapper.stage(Main, groovy.lang.Closure)
            buildWrapper.sh({script=python -c "import requests", returnStatus=true})
            buildWrapper.sh(docker version)
         buildWrapper.stage(Post, groovy.lang.Closure)
            buildWrapper.sh(ls -al)
            buildWrapper.sh(java -version)
            buildWrapper.sh(mvn -s dummy.xml -version)
            buildWrapper.sh(python -V)
```

For automated detection of regression, we need to save the expected call stack above into a file into a location known to JenkinsPipelineUnit.
You can specify the location of such call stacks by overriding the field `callStackPath` of BaseRegressionTest in `setUp` method.
The file name should follow the convention `${ClassName}_${subname}.txt` where `subname` is specified by `testNonRegression` method in each test case.
Then, you can update the above test case to perform regression check as follows:

``` groovy
  @Test
  public void configured() throws Exception {
    def script = loadScript('vars/demoWrapper.groovy')
    script.call({
      settings = "dummy.xml"
    })

    // printCallStack()
    testNonRegression("configured")
  }
```

In this example, the above call stack should be saved into `DemoTest_configured.txt` file at the location specified by `callStackPath`.
Similarly, you can also have another unit test for the other use case of `buildWrapper`.

``` groovy
  /**
   * Represent the call:
   * buildWrapper {
   * }
   *
   * @throws Exception
   */
  @Test
  public void default_value() throws Exception {
    def script = loadScript('vars/buildWrapper.groovy')
    script.call({})

    // printCallStack()
    testNonRegression("default")
  }
```

This [example class](https://github.com/tdongsi/jenkins-steps-override/blob/master/test/vars/BuildWrapperTest.groovy) shows a complete example, together with [files of expected call stacks](https://github.com/tdongsi/jenkins-steps-override/tree/master/test/vars/callstacks).

TODO: View diff in IntelliJ.

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

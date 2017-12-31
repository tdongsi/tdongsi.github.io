---
layout: post
title: "Groovy Hook Script and Jenkins Configuration as Code"
date: 2017-12-30 21:02:48 -0800
comments: true
categories: 
- Jenkins
- Groovy
---

This post discusses [Groovy Hook Scripts](https://wiki.jenkins.io/display/JENKINS/Groovy+Hook+Script) and how to use them for full configuration-as-code in Jenkins with Docker, Pipeline.
This can help us to set up local environment for developing Jenkins Pipeline libraries and to evaluate various Jenkins features.

<!--more-->

### Groovy Hook Scripts

These scripts are written in Groovy, and get executed inside the same JVM as Jenkins, allowing full access to the domain model of Jenkins. 
For given hook `HOOK`, the following locations are searched:

```
WEB-INF/HOOK.groovy in jenkins.war
WEB-INF/HOOK.groovy.d/*.groovy in the lexical order in jenkins.war
$JENKINS_HOME/HOOK.groovy
$JENKINS_HOME/HOOK.groovy.d/*.groovy in the lexical order
```

The `init` is the most commonly used hook.

### Authorization

"Logged-in users can do anything".

``` groovy
import jenkins.model.*
def instance = Jenkins.getInstance()

import hudson.security.*
def realm = new HudsonPrivateSecurityRealm(false)
instance.setSecurityRealm(realm)

def strategy = new hudson.security.FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()
```

Matrix-based authorization: Gives all authenticated users admin access:

``` groovy Matrix-based authorization
import jenkins.model.*
def instance = Jenkins.getInstance()

import hudson.security.*
def realm = new HudsonPrivateSecurityRealm(false)
instance.setSecurityRealm(realm)

def strategy = new hudson.security.GlobalMatrixAuthorizationStrategy()
strategy.add(Jenkins.ADMINISTER, 'authenticated')
instance.setAuthorizationStrategy(strategy)

instance.save()
```

Make sure [`matrix-auth` plugin](https://wiki.jenkins.io/display/JENKINS/Matrix+Authorization+Strategy+Plugin) is installed before you can import GlobalMatrixAuthorizationStrategy class.
For full list of standard permissions in the matrix, see [this code snippet](https://gist.github.com/jnbnyc/c6213d3d12c8f848a385).
Note that the matrix can be different if different plugins are installed.
For example, the "Replay" permission for Runs is not simply `hudson.model.Run.REPLAY` since there is no such static constant.
Such permission is only available after [Workflow CPS plugin](https://github.com/jenkinsci/workflow-cps-plugin) is installed.
Therefore, we can only set "Replay" permission for Runs with the following:

``` groovy
strategy.add(org.jenkinsci.plugins.workflow.cps.replay.ReplayAction.REPLAY,USER)
```

### Notifications

```groovy Configure Slack
import jenkins.model.*
def instance = Jenkins.getInstance()

// configure slack
def slack = Jenkins.instance.getExtensionList(
  jenkins.plugins.slack.SlackNotifier.DescriptorImpl.class
)[0]
def params = [
  slackTeamDomain: "domain",
  slackToken: "token",
  slackRoom: "",
  slackBuildServerUrl: "$JENKINS_URL",
  slackSendAs: ""
]
def req = [
  getParameter: { name -> params[name] }
] as org.kohsuke.stapler.StaplerRequest
slack.configure(req, null)
slack.save()
```

```groovy Global email settings
import jenkins.model.*
def instance = Jenkins.getInstance()

// set email
def location_config = JenkinsLocationConfiguration.get()
location_config.setAdminAddress("jenkins@skynet.net")
```

### Tools

JDKs and Maven can be setup with the following ([reference](https://github.com/oleg-nenashev/demo-jenkins-config-as-code/blob/master/init_scripts/src/main/groovy/scripts/Tools.groovy)):

``` groovy Setup JDKs and Maven
import jenkins.model.Jenkins
import hudson.model.JDK
import hudson.tasks.Maven.MavenInstallation;
import hudson.tasks.Maven
import hudson.tools.InstallSourceProperty

println("--- Setup tool installations")
// By default we offer no JDK7, Nodes should override
JDK jdk7 = new JDK("jdk7", "/non/existent/JVM")
// Java 8 should be a default Java, because we require it for Jenkins 2.60.1+
JDK jdk8 = new JDK("jdk8", "")
Jenkins.instance.getDescriptorByType(JDK.DescriptorImpl.class).setInstallations(jdk7, jdk8)

InstallSourceProperty p = new InstallSourceProperty([new Maven.MavenInstaller("3.5.0")])
MavenInstallation mvn = new MavenInstallation("mvn", null, [p])
Jenkins.instance.getDescriptorByType(Maven.DescriptorImpl.class).setInstallations(mvn)

// Configure global maven options
def maven = Jenkins.instance.getExtensionList(
  hudson.maven.MavenModuleSet.DescriptorImpl.class
)[0]
maven.setGlobalMavenOpts("-Dmaven.test.failure.ignore=false")
maven.save()
```

### References

* [Groovy Hook Script](https://wiki.jenkins.io/display/JENKINS/Groovy+Hook+Script)
* [Matrix-based Authorizaiton](https://gist.github.com/jnbnyc/c6213d3d12c8f848a385)
* [Jenkins config as code](https://github.com/oleg-nenashev/demo-jenkins-config-as-code)
---
layout: post
title: "Groovy Hook Script and Jenkins Configuration as Code"
date: 2017-12-30 21:02:48 -0800
comments: true
categories: 
- Jenkins
- Groovy
- Security
---

This post discusses [Groovy Hook Scripts](https://wiki.jenkins.io/display/JENKINS/Groovy+Hook+Script) and how to use them for full configuration-as-code in Jenkins with Docker, Pipeline.
This can help us to set up local environment for developing Jenkins Pipeline libraries and to evaluate various Jenkins features.

<!--more-->

### Groovy Hook Scripts

These scripts are written in Groovy, and get executed inside the same JVM as Jenkins, allowing full access to the domain model of Jenkins. 
For a given hook `HOOK`, the following locations are searched:

```
WEB-INF/HOOK.groovy in jenkins.war
WEB-INF/HOOK.groovy.d/*.groovy in the lexical order in jenkins.war
$JENKINS_HOME/HOOK.groovy
$JENKINS_HOME/HOOK.groovy.d/*.groovy in the lexical order
```

The `init` is the most commonly used hook (i.e., `HOOK=init`).
The following sections show how some of the most common tasks and configurations in Jenkins can be achieved by using such Groovy scripts.
For example, in [this project](https://github.com/tdongsi/jenkins-config), many of such scripts are added into a Dockerized Jenkins master and executed when
starting a container to replicate configurations of the Jenkins instance in production.
It will give us ability to quickly spin up local Jenkins instances for development or troubleshooting issues in production Jenkins.

On a side note, IntelliJ IDEA is probably the best development tool for working with these Groovy Scripts.
Check out [these instructions on how to set it up in IntelliJ](https://github.com/tdongsi/jenkins-config/blob/develop/docs/IDE.md).
*UPDATED ON 2018/09/29*: More on IntelliJ setup is discussed in [this blog post](/blog/2018/02/09/intellij-setup-for-jenkins-shared-library-development/).

### Authorization

This section shows how to enable different authorization strategies in Groovy code.

``` groovy "Logged-in users can do anything"
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

For importing GlobalMatrixAuthorizationStrategy class, make sure that [`matrix-auth` plugin](https://wiki.jenkins.io/display/JENKINS/Matrix+Authorization+Strategy+Plugin) is installed.
For full list of standard permissions in the matrix, see [this code snippet](https://gist.github.com/jnbnyc/c6213d3d12c8f848a385).
Note that the matrix can be different if different plugins are installed.
For example, the "Replay" permission for Runs is not simply `hudson.model.Run.REPLAY` since there is no such static constant.
Such permission is only available after [Workflow CPS plugin](https://github.com/jenkinsci/workflow-cps-plugin) is installed.
Therefore, we can only set "Replay" permission for Runs with the following:

``` groovy
strategy.add(org.jenkinsci.plugins.workflow.cps.replay.ReplayAction.REPLAY,USER)
```

**References**

* [Matrix-based Authorizaiton](https://gist.github.com/jnbnyc/c6213d3d12c8f848a385)
* [Jenkins config as code](https://github.com/oleg-nenashev/demo-jenkins-config-as-code)

### Basic Jenkins security

In addition to enable authorization strategy, we should also set some basic configurations for hardening Jenkins.
Those includes various options that you see in Jenkins UI when going to Manage Jenkins > Configure Global Security.

* [Disable Jenkins CLI](https://support.cloudbees.com/hc/en-us/articles/234709648-Disable-Jenkins-CLI)
* Limit Jenkins agent protocols.
* "Enable Slave -> Master Access Control"
* "Prevent Cross Site Request Forgery exploits"

``` groovy Basic Jenkins security
import hudson.security.csrf.DefaultCrumbIssuer
import jenkins.model.Jenkins
import jenkins.model.JenkinsLocationConfiguration
import jenkins.security.s2m.AdminWhitelistRule
import org.kohsuke.stapler.StaplerProxy
import hudson.tasks.Mailer

println("--- Configuring Remoting (JNLP4 only, no Remoting CLI)")
Jenkins.instance.getDescriptor("jenkins.CLI").get().setEnabled(false)
Jenkins.instance.agentProtocols = new HashSet<String>(["JNLP4-connect"])

println("--- Enable Slave -> Master Access Control")
Jenkins.instance.getExtensionList(StaplerProxy.class)
    .get(AdminWhitelistRule.class)
    .masterKillSwitch = false

println("--- Checking the CSRF protection")
if (Jenkins.instance.crumbIssuer == null) {
    println "CSRF protection is disabled, Enabling the default Crumb Issuer"
    Jenkins.instance.crumbIssuer = new DefaultCrumbIssuer(true)
}

println("--- Configuring Quiet Period")
// We do not wait for anything
Jenkins.instance.quietPeriod = 0
Jenkins.instance.save()

println("--- Configuring Email global settings")
JenkinsLocationConfiguration.get().adminAddress = "admin@non.existent.email"
Mailer.descriptor().defaultSuffix = "@non.existent.email"
```

Some are not working for versions before 2.46, according to [this](https://support.cloudbees.com/hc/en-us/articles/234709648-Disable-Jenkins-CLI).
For disabling Jenkins CLI, you can simply add the java argument `-Djenkins.CLI.disabled=true` on Jenkins startup.

**References**

* [Disable Jenkins CLI: different versions](https://support.cloudbees.com/hc/en-us/articles/234709648-Disable-Jenkins-CLI)
* [Slave to Master Access Control](https://wiki.jenkins.io/display/JENKINS/Slave+To+Master+Access+Control)

### Create Jobs and Items

``` groovy Create "Pipeline script from SCM" job
import hudson.plugins.git.*;

def scm = new GitSCM("git@github.com:dermeister0/Tests.git")
scm.branches = [new BranchSpec("*/develop")];

def flowDefinition = new org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition(scm, "Jenkinsfile")

def parent = Jenkins.instance
def job = new org.jenkinsci.plugins.workflow.job.WorkflowJob(parent, "New Job")
job.definition = flowDefinition
```

* [Stackoverflow thread](https://stackoverflow.com/questions/16963309/how-create-and-configure-a-new-jenkins-job-using-groovy)
* [More example](https://github.com/linagora/james-jenkins/blob/master/create-dsl-job.groovy)

### Create different kinds of Credentials

Adding Credentials to a new, local Jenkins for development or troubleshooting can be a daunting task.
However, with the following scripts and the right setup (NEVER commit your secrets into VCS), developers can automate adding the required Credentials into the new Jenkins.

```groovy Preamble
import com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl
import org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl
import org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl
import com.cloudbees.plugins.credentials.domains.Domain
import com.cloudbees.plugins.credentials.CredentialsScope
import jenkins.model.Jenkins
import hudson.util.Secret
import com.cloudbees.jenkins.plugins.sshcredentials.impl.BasicSSHUserPrivateKey
import com.cloudbees.plugins.credentials.impl.CertificateCredentialsImpl
import com.cloudbees.plugins.credentials.SecretBytes

def domain = Domain.global()
def store = Jenkins.instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0].getStore()
```

```groovy "Username with Password" type
def githubAccount = new UsernamePasswordCredentialsImpl(
        CredentialsScope.GLOBAL, "test-github", "Test Github Account",
        "testuser",
        "testpassword"
)
store.addCredentials(domain, githubAccount)
```

```groovy "Secret text" type
def secretString = new StringCredentialsImpl(
        CredentialsScope.GLOBAL, "test-secret-string", "Test Secret String",
        Secret.fromString("testpassword")
)
store.addCredentials(domain, secretString)
```

```groovy "Secret file" type
// Text file
def secret = '''Hi,
This is the content of the file.
'''

def secretBytes = SecretBytes.fromBytes(secret.getBytes())
def secretFile = new FileCredentialsImpl(
  CredentialsScope.GLOBAL, 
  'text-secret-file', 
  'description', 
  'file.txt', 
  secretBytes)
store.addCredentials(domain, secretFile)

// Binary file
Path fileLocation = Paths.get("/path/to/some/file.tar");
def secretBytes = SecretBytes.fromBytes(Files.readAllBytes(fileLocation))
def secretFile = new FileCredentialsImpl(
  CredentialsScope.GLOBAL, 
  'binary-secret-file', 
  'description', 
  'file.tar', 
  secretBytes)
store.addCredentials(domain, secretFile)
```

```groovy "SSH Username with private key" type
String keyfile = "/var/jenkins_home/.ssh/id_rsa"
def privateKey = new BasicSSHUserPrivateKey(
        CredentialsScope.GLOBAL,
        "jenkins_ssh_key",
        "git",
        new BasicSSHUserPrivateKey.FileOnMasterPrivateKeySource(keyfile),
        "",
        ""
)
store.addCredentials(domain, privateKey)
```

```groovy "Certificate" type
String minikubeKeyfile = "/var/jenkins_home/secret_data/minikube.pfx"
def minikubeCreds = new CertificateCredentialsImpl(
        CredentialsScope.GLOBAL,
        "minikube",
        "Minikube client certificate",
        "secret",
        new CertificateCredentialsImpl.FileOnMasterKeyStoreSource(minikubeKeyfile))
store.addCredentials(domain, minikubeCreds)
```

* [CloudBees tutorial](https://support.cloudbees.com/hc/en-us/articles/217708168-create-credentials-from-groovy)
* [Examples](https://github.com/tdongsi/jenkins-config/blob/develop/init_scripts/src/main/groovy/scripts/Credentials.groovy)

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

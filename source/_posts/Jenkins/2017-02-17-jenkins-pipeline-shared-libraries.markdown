---
layout: post
title: "Updating Jenkins Pipeline Shared Libraries"
date: 2017-03-17 14:38:14 -0800
comments: true
published: true
categories: 
- Jenkins
- Git
- Groovy
---

When you have multiple Pipeline jobs, you often want to share some parts of the Jenkinsfiles between them to keep Jenkinfiles [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself). 
A very common use case is that you have many projects that are built in the similar way, such as Nexus authentication step in Gradle build.
One way is to use [Workflow plugin](https://github.com/jenkinsci/workflow-cps-global-lib-plugin).
Comprehensive user documentation can be found in [this section](https://jenkins.io/doc/book/pipeline/shared-libraries/) of Jenkins handbook.

In the following sections, we review a couple **older**, but not necessarily worse, ways of updating shared Groovy code which are still used in some Jenkins system.

<!--more-->

### Simple copying

A quick and dirty way of updating shared Groovy codes in Jenkinsfile is to overwrite Groovy files on Jenkins in its `$JENKINS_HOME`. 
All such Groovy files are stored in *$JENKINS_HOME/workflow-libs* folder, following this directory structure:

``` plain Directory structure of a Shared Library repository
(root)
+- src                     # Groovy source files
|   +- org
|       +- foo
|           +- Bar.groovy  # for org.foo.Bar class
+- vars
|   +- foo.groovy          # for global 'foo' variable
|   +- foo.txt             # help for 'foo' variable
+- resources               # resource files (external libraries only)
|   +- org
|       +- foo
|           +- bar.json    # static helper data for org.foo.Bar
```

By manually modifying the Groovy files (e.g., *vars/foo.groovy*) and restarting Jenkins, you can update their behaviors accordingly. 
This method is dirty and definitely bad since it requires a Jenkins restart and modifications to Groovy codes are not tracked (and code-reviewed) anywhere.

### Git-based update

A more scalable alternative for updating Groovy codes is to use `git push`, exposed by Jenkins.

As a side note, this method is no longer mentioned in documentation, as of March 2017.
In fact, you have to look into a [very old commit](https://github.com/jenkinsci/workflow-cps-global-lib-plugin/tree/ce1177278d4cb05ac6b01f723177cc4b2e0aec8d) 
or [outdated, unofficial fork](https://github.com/cloudbees/workflow-plugin/tree/master/cps-global-lib) to find this method briefly mentioned at all.
It is also occasionally mentioned in support articles such as [this](https://support.cloudbees.com/hc/en-us/articles/218162277-Unable-to-Clone-workflowLibs).

In this method, the directory *$JENKINS_HOME/workflow-libs* is exposed by Jenkins as a Git repository. 
You can deploy new changes to this directory through `git push` and any such event will trigger Jenkins to recompile Groovy files. 
There is no Jenkins restart required for this method, which makes it much more suitable for production Jenkins.
The Git repository is exposed in two endpoints:

* http://server/jenkins/workflowLibs.git (when your Jenkins is `http://server/jenkins/`).
* ssh://USERNAME@server:PORT/workflowLibs.git (when Jenkins acts as [an SSH server](https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+SSH))

This method also means that the shared Jenkins library scripts in Groovy are stored in another Git repository (e.g., "shared-lib" on Github) and only `git push` to the `workflowLibs.git` repository in the event of deployment.
Having the shared scripts in Git allows you to track changes, perform tested deployments, and reuse the same shared library across a large number of instances.

#### Jenkinsfile to update global library

In this Git-based update approach, all Groovy files should be in some Git repository (e.g., "shared-lib") with certain directory structure (shown in the last section). 
Since Jenkinsfile has been extensively used for creating CI/CD pipelines, it is only appropriate to add a Jenkinsfile for deploying Groovy files in this Git repository to update Jenkins.
The Jenkinsfile for such workflow-libs should be as follows:

``` plain Jenkinsfile for deployment
  stage 'Checkout'
  checkout scm

  if (env.BRANCH_NAME == 'master') {
    stage 'Update'
    println "Updating Jenkins workflow-libs"
    sshagent(['jenkins_ssh_key']) {
      sh """
         git branch master
         git checkout master
         ssh-keyscan -H -p 12222 \${JENKINS_ADDR} >> ~/.ssh/known_hosts
         git remote add jenkins ssh://tdongsi@\${JENKINS_ADDR}:12222/workflowLibs.git
         git push --force jenkins master
      """
    }
  }
```

Some comments on this Jenkinsfile:

* `sshagent(['jenkins_ssh_key'])` indicates that the current node/slave is known as [an SSH agent](https://wiki.jenkins-ci.org/display/JENKINS/SSH+Agent+Plugin) to Jenkins master, using Jenkins credentials with ID `jenkins_ssh_key`. 
* `git remote add` uses the currently checked out Git repo and branch as a remote branch (named "jenkins") to the `workflowLibs` repository.
* The `workflowLibs` repository is managed by Jenkins, exposed at that location *ssh://tdongsi@\${JENKINS_ADDR}:12222/workflowLibs.git*. 
* Then we force push any new changes to the Git repository on Jenkins. 

After the push, the Git repository `workflowLibs` on Jenkins should have latest change, same as the current "shared-lib" repository.
Upon a `git push` event, the Jenkins will automatically update its global library with the latest changes, without the need of restarting.
Note that for this SSH push to work, a public-private key pair must be generated and configured accordingly.

``` plain Key pair generation
mymac:jenkins tdongsi$ kubectl --namespace=jenkins exec -ti jenkins-ideb4 -- bash

jenkins@jenkins-4076880321-ideb4:~$ ssh-keygen -t rsa -b 4096 -C "example@gmail.com"
Generating public/private rsa key pair.
Enter file in which to save the key (/var/jenkins_home/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
```

The generated public key should be added to the user via *jenkinsurl.com/user/tdongsi/configure* URL and private key should be added to the credentials ID `jenkins_ssh_key`.

### References

* [Git-based update](https://github.com/cloudbees/workflow-plugin/tree/master/cps-global-lib)

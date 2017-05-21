---
layout: post
title: "Jenkins Pipeline Shared Libraries"
date: 2017-03-17 14:38:14 -0800
comments: true
published: true
categories: 
- Jenkins
- Git
- Groovy
---

Use Jenkinsfile as Infrastructure as Code.

When you have multiple Pipeline jobs, you often want to share some parts of the Jenkinsfiles between them to keep Jenkinfiles [DRY](https://en.wikipedia.org/wiki/Don't_repeat_yourself). 
A very common use case is that you have many projects that are built in the similar way.
One way is to use [Workflow plugin](https://github.com/jenkinsci/workflow-cps-global-lib-plugin).

Comprehensive user documentation can be found in [this section](https://jenkins.io/doc/book/pipeline/shared-libraries/) of Jenkins handbook.

However, there is an older way of sharing code is to deploy the Groovy sources to Jenkins.

1) Copy to the folder and restart Jenkins.

http://stackoverflow.com/questions/29826559/loading-multiple-build-scripts-dry-using-jenkins-workflow-plugin

`git pull` and then restart.

2) A more scalable solution is to use Git, exposed by Jenkins.

This older method is no longer mentioned in documentation, as of February 2017.
In fact, you have to look into a [very old commit](https://github.com/jenkinsci/workflow-cps-global-lib-plugin/tree/ce1177278d4cb05ac6b01f723177cc4b2e0aec8d) 
or [outdated, unofficial fork](https://github.com/cloudbees/workflow-plugin/tree/master/cps-global-lib) to find this method briefly mentioned at all.

It is also occasionally mentioned in support articles such as [this](https://support.cloudbees.com/hc/en-us/articles/218162277-Unable-to-Clone-workflowLibs).

Jenkins acts as [an SSH server](https://wiki.jenkins-ci.org/display/JENKINS/Jenkins+SSH).

### Jenkinsfile to update global library

```
  stage 'Checkout'
  checkout scm

  if (env.BRANCH_NAME == 'master') {
    stage 'Commit'
    println "Committing to Jenkins Global Library"
    sshagent(['jenkins_ssh_key']) {
      sh """
         git branch master
         git checkout master
         ssh-keyscan -H -p 12222 \${JENKINS_PORT_12222_TCP_ADDR} >> ~/.ssh/known_hosts
         git remote add jenkins ssh://tdongsi@\${JENKINS_PORT_12222_TCP_ADDR}:12222/workflowLibs.git
         git push --force jenkins master
      """
    }
  }
```

`sshagent(['jenkins_ssh_key'])` indicates that the current slave is known as an SSH agent to Jenkins master, 
using Jenkins credentials with ID `jenkins_ssh_key`. 
The credential `jenkins_ssh_key` is a global.

The stage "Checkout" checks out the latest code from Git repo (the same repository and branch of the current Jenkinsfile).
`git remote add` uses the currently checked out Git repo and branch as a remote branch (named "jenkins") to the `workflowLibs` repository.
The `workflowLibs` repository is managed by Jenkins, exposed at that location. 
Then we force push any new changes to the Git repository on Jenkins. 
After the push, the Git repository `workflowLibs` on Jenkins should have latest change.
The cool thing about this setup is that upon a push event, the Jenkins will automatically update its global library, without the need of restarting.

### References

* https://github.com/jenkinsci/workflow-remote-loader-plugin


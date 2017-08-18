---
layout: post
title: "Github REST API Cookbook"
date: 2017-08-06 21:37:20 -0700
comments: true
categories: 
- bash
- Jenkins
- Groovy
---

The blog post shows some useful snippets for interacting with Github API.
Jenkins pipelines regularly interacts with Github (public or Enterprise) API to perform some query/posting, for example, regarding the current pull request.
For that reason, some of the following snippets are either in Groovy or `curl` commands embedded in Groovy-based Jenkinsfile code with some Jenkinsfile DSLs.

<!--more-->

### Working with Pull Requests

#### Merge pull request

``` groovy Merge pull request
stage ("Merge PR") {
    steps { 
        withCredentials([usernamePassword(credentialsId: 'credential-value', usernameVariable: 'ACCESS_TOKEN_USERNAME', passwordVariable: 'ACCESS_TOKEN_PASSWORD',)]) {
            def GITHUB = 'https://github.ibm.com/api/v3/repos'
            sh "curl -X PUT -d '{\"commit_title\": \"Merge pull request\"}' ${GITHUB}/org-name/repo-name/pulls/${env.CHANGE_ID}/merge?access_token=${env.ACCESS_TOKEN_PASSWORD}"
        }
    }
}
```

The Jenkins-provided environment variable `$CHANGE_ID`, in the case of a pull request, is the pull request number.

#### Extracting pull request

``` groovy Get PR body text
import groovy.json.JsonSlurper

def getPrBody(String githubUsername, String githubToken, String repo, String id) {
  String GITHUB_API = 'https://git.enterprise.com/api/v3/repos'

  String url = "${GITHUB_API}/${githubUsername}/${repo}/pulls/${id}"
  println "Querying ${url}"
  def text = url.toURL().getText(requestProperties: ['Authorization': "token ${githubToken}"])
  def json = new JsonSlurper().parseText(text)
  def bodyText = json.body
  
  return bodyText
}
```

#### Posting comment

### Working with Branches

#### Getting email of branch maintainer

TODO: Note that in Git, there is no such metadata for Git creator.

``` groovy Get email of branch maintainer.
def getBranchCreator(String githubUsername, String githubToken, String repo, String branch) {
    String GITHUB_API = 'https://git.enterprise.com/api/v3/repos'

    String url = "${GITHUB_API}/${githubUsername}/${repo}/branches/${branch}"
    println "Querying ${url}"
    def text = url.toURL().getText(requestProperties: ['Authorization': "token ${githubToken}"])
    def json = new JsonSlurper().parseText(text)

    // Get last committer.
    def creator = json.commit.commit.committer.email
    // TRICKY: json.commit.commit.committer.email is not valid if someone commits from Github web interface.
    // In the case, committer name is 'GitHub Enterprise'.
    if (json.commit.commit.committer.name == 'GitHub Enterprise') {
    // Use author's email instead
    creator = json.commit.commit.author.email
    }
    // TRICKY: the following can return inconsistent data, including "null".
    // def author = json.author
    return creator
}

// Calling from Jenkinsfile
withCredentials([
    [$class: 'UsernamePasswordMultiBinding', credentialsId: 'my-credentials', 
        passwordVariable: 'GITHUB_PASSWORD', usernameVariable: 'GITHUB_USERNAME']
]) {
    if (env.BRANCH_NAME ==~ /PR-\d+/ ) {
        // If it is a PR build, use some distribution list
        email = 'someemail@enterprise.com'
    } else {
        // TODO: Replace env.GITHUB_USERNAME with the correct Github org name.
        email = getBranchCreator(env.GITHUB_USERNAME, env.GITHUB_PASSWORD, 'my_repo', env.BRANCH_NAME)
    }
}  
```

### Tips

TODO: maintainer vs author.

TODO: Groovy or `curl` what do you want to do with it.

### Reference

Evernote: Github REST API



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

#### Extracting Pull Request details

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

The equivalent `curl` command is as follows, with JSON processing is done in `jq`:

``` groovy Equivalent curl | jq command in Jenkisfile
sh """
curl -s -H "Authorization: token ${env.GITHUB_TOKEN}" ${GITHUB_API}/${org}/${repo}/pulls/${env.CHANGE_ID} | jq '.body' -r > pr_body.txt
"""
```

#### Posting comment on the Pull Request

Reference: [Create a comment](https://developer.github.com/v3/issues/comments/#create-a-comment)

``` groovy Equivalent curl in Jenkinsfile
sh """
curl -s -X POST -H "Authorization: token ${env.GITHUB_TOKEN}" --data '{"body": "${comment}"}' ${GITHUB_API}/${org}/${repo}/issues/${env.CHANGE_ID}/comments
"""
```

#### Merge Pull Request

Based on [this article](http://www.cloudypoint.com/Tutorials/discussion/jenkins-solved-how-to-merge-a-successful-build-of-a-pull-request-using-a-jenkinsfile/
).

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

### More tips on Github API

TODO: maintainer vs author.

TODO: Groovy or `curl` what do you want to do with it.

There is an API rate limit for public Github API (note "X-RateLimit-Limit" and "X-RateLimit-Remaining" in output below).

``` plain Github API limit
tdongsi-mac:dev tdongsi$ curl -i https://api.github.com/users/tdongsi
HTTP/1.1 200 OK
Date: Fri, 09 Jun 2017 16:16:49 GMT
Content-Type: application/json; charset=utf-8
Content-Length: 1236
Server: GitHub.com
Status: 200 OK
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 55
X-RateLimit-Reset: 1497025098
Cache-Control: public, max-age=60, s-maxage=60
Vary: Accept
ETag: "4d7770cf5c2478bf64d23bc908494172"
Last-Modified: Thu, 01 Jun 2017 01:09:00 GMT
X-GitHub-Media-Type: github.v3; format=json
Access-Control-Expose-Headers: ETag, Link, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval
Access-Control-Allow-Origin: *
Content-Security-Policy: default-src 'none'
Strict-Transport-Security: max-age=31536000; includeSubdomains; preload
X-Content-Type-Options: nosniff
X-Frame-Options: deny
X-XSS-Protection: 1; mode=block
X-Runtime-rack: 0.030687
Vary: Accept-Encoding
X-Served-By: 62cdcc2d03a2f173f1c58590d1a90077
Vary: Accept-Encoding
X-GitHub-Request-Id: FADF:2CB6E:44F743B:56EDC6F:593AC9F1

...
```

You are likely to hit this rate limit quickly if you are polling the repos for updates.
Instead of polling from your CI (e.g., Jenkins) system, it is recommended to use [Github webhooks](https://developer.github.com/webhooks/creating/).

### Reference

Evernote: Github REST API



---
layout: post
title: "Github REST API Cookbook"
date: 2017-08-06 21:37:20 -0700
comments: true
categories: 
- bash
- Jenkins
- Groovy
- Git
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

Reference: [Create a comment](https://developer.github.com/v3/issues/comments/#create-a-comment).

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

At the end of a Jenkins build for a feature branch (NOT `develop`/`master`), you may want to email some developer of its status, as opposed to blasting a whole distribution list.
Note that in Git, there is no such metadata for branch creator, as discussed [here](https://stackoverflow.com/questions/12055198/find-out-git-branch-creator/19135644).
Instead, it makes more sense to notify the latest/active committer which is likely the owner of the branch.

<!--
Furthermore, while most of the branches in Git has short lifetime, some branches such as `master` and `develop` can stay around for a long time.
That person may be not active or leave the project entirely.
-->

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
        // NOTE: Replace env.GITHUB_USERNAME with the correct Github org name.
        email = getBranchCreator(env.GITHUB_USERNAME, env.GITHUB_PASSWORD, 'my_repo', env.BRANCH_NAME)
    }
}  
```

#### Deleting a branch

Searching how to delete a branch in Github API's [Branches reference](https://developer.github.com/v3/repos/branches/) does not return anything.
In fact, to delete a branch, we have to delete its HEAD reference as shown [here](https://developer.github.com/v3/git/refs/#delete-a-reference).

``` plain Deleting a branch
DELETE /repos/octocat/Hello-World/git/refs/heads/feature-a
```

### More tips on Github API

1) When processing data from Github API, note that any commit has an author and a committer, as shown below. 

``` json Example commit data
        "commit": {
            "author": {
                "name": "Cuong Dong-Si",
                "email": "tdongsi@example.com",
                "date": "2017-08-17T05:33:46Z"
            },
            "committer": {
                "name": "Tue-Cuong Dong-Si",
                "email": "tdongsi@example.com",
                "date": "2017-08-17T05:33:46Z"
            },
            "message": "@JIRA-4214772@: Add function.",
            "tree": {
                "sha": "xxx",
                "url": "xxx"
            },
            "url": "xxx",
            "comment_count": 0
        },
```

While the two fields are usually the same in normal commits (with same associated email and timestamp), they have different meanings.
In summary, the author is the one who created the content, and the committer is the one who committed it.
The two fields can be different in some common Github workflows:

* Commit a change from Github web interface: The author is the logged-in user (e.g., tdongsi) but the "committer" field usually has the Github default name and email, e.g., "Github Enterprise" and "no-reply@github.com".
* Make and/or merge a pull request from Github: For example, Alice submitted a pull request which was accepted and then merged by Betty (the repository owner). In that case, the author is Alice and the committer is Betty.

Due to that subtle difference in committer and author in different scenarios, one has to be careful when using data sent by Github API in a Jenkins pipeline. 
For example, you want to send email to the repository owner (committer) at the end of a Pull Request build, but what if someone adds a commit via Github web interface (commiter email would be "no-reply@github.com" which is not helpful).

2) There is an API rate limit for the free public Github API (note "X-RateLimit-Limit" and "X-RateLimit-Remaining" in output below).

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

* [curl cookbook](/blog/2015/08/04/curl-cookbook/)



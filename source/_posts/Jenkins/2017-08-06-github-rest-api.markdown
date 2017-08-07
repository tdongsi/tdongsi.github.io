---
layout: post
title: "Github REST API Cookbook"
date: 2017-08-06 21:37:20 -0700
comments: true
categories: 
- bash
- Jenkins
---

The blog post showcases some useful snippets for interacting with Github API.
Jenkins pipelines regularly interacts with Github (public or Enterprise) API to perform some query/posting, for example, regarding the current pull request.
For that reason, some of the following snippets are `curl` commands embedded in Groovy-based Jenkinsfile code.

<!--more-->

### Merge pull request

``` groovy Merge pull request
stage ("Merge PR") {
    steps { 
        withCredentials([usernamePassword(credentialsId: 'credential-value', usernameVariable: 'ACCESS_TOKEN_USERNAME', passwordVariable: 'ACCESS_TOKEN_PASSWORD',)]) {
            sh "curl -X PUT -d '{\"commit_title\": \"Merge pull request\"}'  https://github.ibm.com/api/v3/repos/org-name/repo-name/pulls/${env.CHANGE_ID}/merge?access_token=${env.ACCESS_TOKEN_PASSWORD}"
        }
    }
}
```

The Jenkins-provided environment variable `$CHANGE_ID`, in the case of a pull request, is the pull request number.

### Posting comment




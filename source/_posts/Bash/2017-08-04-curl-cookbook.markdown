---
layout: post
title: "curl Cookbook"
date: 2015-08-04 10:43:42 -0700
comments: true
categories:
- Bash 
- Security
- Git
---

This blog lists some recipes for `curl` command.

<!--more-->

### Alternatives to `curl`

#### Simple connectivity test

`telnet`: Most of `curl` uses are to simply check if you can connect to some endpoint at some port number.

`python`: In some Linux systems, `telnet` is not installed and cannot be installed but `python` is present. In that case, you can use the following Python snippet:

``` plain Connectivity test with Python
$ python
Python 2.7.5 (default, Nov  6 2016, 00:28:07)
[GCC 4.8.5 20150623 (Red Hat 4.8.5-11)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import socket
>>> s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
>>> s.connect(('my.service.net',8080))
``` 

#### Full replacement

`java`: [Apache HttpClient](https://hc.apache.org/index.html).

`python`: [requests module](http://docs.python-requests.org/en/master/). An [example project](https://github.com/tdongsi/bart-parking).

`groovy`: String's `toURL().getText()` together with JsonSlurper. 

``` groovy Example Groovy
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

### Standard options by functionality

#### General usage

``` plain Options
-X: HTTP method. For example: -X PUT.
-O: binary download.

-s: silent. It will only output the data you ask for.
```

#### Secure connections

``` plain Options
-k, --insecure: curl to proceed and operate even for server connections otherwise considered insecure.
```

### Cookbook

#### Standard usage

``` plain etcd examples
curl -X GET http://master-1:2379/v2/keys/coreos.com/network/config
```

Some examples with [Github API](/blog/2017/08/06/github-rest-api/).

``` plain Other Github API examples
# PUT with data: Merging a PR
curl -X PUT -d '{\"commit_title\": \"Merge pull request\"}' ${GITHUB}/org-name/repo-name/pulls/${env.CHANGE_ID}/merge?access_token=${env.ACCESS_TOKEN_PASSWORD}

# GET with authentication: Get PR details
curl -s -H "Authorization: token ${env.GITHUB_TOKEN}" ${GITHUB}/${org}/${repo}/pulls/${env.CHANGE_ID}

# With proxy
curl -L -x public0-proxy1.company.net:8080 https://api.github.com
```

### Common problems

#### Passing certificate and private key gives `OSStatus -25299` error

You might encounter the following problem with the default `curl` on MacOS. 

``` plain Error message
tdongsi-ltm4:download tdongsi$ curl --cert hostcert.crt --key hostcert.key "https://myurl:9093/namespaces/something"
curl: (58) SSL: Can't load the certificate "hostcert.crt" and its private key: OSStatus -25299
```

As explained in [this Github bug](https://github.com/curl/curl/issues/283), the certificate must be in PKCS#12 format if using Secure Transport.

{% blockquote %}
the Secure Transport back-end to curl only supports client IDs that are in PKCS#12 (P12) format; it does not support client IDs in PEM format because Apple does not allow us to create a security identity from an identity file in PEM format without using a private API. And we can't use the private API, because apps that use private API are not allowed in any of Apple's app stores.
{% endblockquote %}

You can use `openssl` to convert your private key + certificate to PKCS12 format, as follows.

``` plain Convert to PKCS12 and retry
tdongsi-ltm4:download tdongsi$ openssl pkcs12 -export -in hostcert.crt -inkey hostcert.key -out ajna.p12
Enter Export Password:
Verifying - Enter Export Password:

tdongsi-ltm4:download tdongsi$ curl -v -k -E ./ajna.p12:testing "https://myurl:9093/namespaces/something"
```

In the second command above, `testing` is the password of your choice when you create `ajna.p12` keystore with the first command.
Note that if `curl` is installed from `homebrew` on MacOS, you can use the certificate and its key without `openssl` conversion step.

### References

* [curl man page](https://curl.haxx.se/docs/manpage.html)

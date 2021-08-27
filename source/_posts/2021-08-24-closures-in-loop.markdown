---
layout: post
title: "Closures in Loop"
date: 2021-08-24 22:12:43 -0700
comments: true
categories: 
- Golang
- Javascript
- Groovy
- Jenkins
---

In this post, we'll look at a nasty gotcha with closures that can ensare even the most experienced programmers. 
This problem can happen to any programming language that has **closures**.

<!--more-->

Recently, while working in Jenkinsfile, I got stuck with this piece of Groovy code:

``` groovy
def deployedApps = [ 'app1', 'app2', 'app3']
def jobs = [:]

// ERROR: what's wrong with this?
for (String app: deployedApps) {
    jobs[app] = { 
        println(app)  // check status
    }
}

// DEBUG: execute the closure to debug.
for (k in deployedApps) {
    jobs[k]()
}
```

In the above code, the `jobs` variable is a mapping from a string to a closure. 
It is intended for `parallel` step to programmatically create a multi-fork stage in Jenkins.

``` groovy
// Constructing "jobs" variable as above.

stage('Deploy') {
  parallel jobs
}
```

The stage will look like this in BlueOcean interface:

{% img center /images/jenkins/parallel.png Parallel jobs %}

As you can probably guess, the intention is to concurrently deploy/print mulitple distinct applications, colorfully named as `app1` `app2` `app3`, in a Jenkins stage "Deploy".

TODO: However it does not work. Only the **last** one in the list of applications will be deployed/printed out.

``` plain Console log
[Pipeline] stage
[Pipeline] { (Deploy)
[Pipeline] parallel
[Pipeline] { (Branch: app1)
[Pipeline] { (Branch: app2)
[Pipeline] { (Branch: app3)
[Pipeline] echo
app3
[Pipeline] }
[Pipeline] echo
app3
[Pipeline] }
[Pipeline] echo
app3
[Pipeline] }
[Pipeline] // parallel
[Pipeline] }
[Pipeline] // stage
```

Note that this problem has nothing to do with Map or Groovy. It can happen to any language that has closures.

For example: The same above problem can be simplified with list [in Groovy](https://groovyconsole.appspot.com/script/5140979879247872):

``` groovy
// List version
def closures = []
for (int i = 0; i < 5; i++) {
    closures += { println i }
}
closures.each{ it() }
```

The same problem can be seen in [Go language](https://play.golang.org/p/OHhJkCwTGQ8):

``` go
    var closures []func()

    // Functions to Print from 0 to 4
    for idx := 0; idx < 5; idx++ {
        closures = append(closures, func() {
            fmt.Println(idx)
        })
    }

    // Now call them
    for _, f := range closures {
        f()
    }
```

or in JavaScript:

``` javascript
for (var i = 0; i < 5; i++) {
    setTimeout(function() {
        console.log(i);
    }, 0);
}
```

In these List-based examples, "5" (the last values of the list) is printed 5 times.


It turns out that this surprise problem is quite common.
In fact, it is so common that the "Go Programming Language" book dedicates a whole section (5.6.1: Caveat: Capturing iteration variables) in its Chapter 5 to talk about this gotcha.

TODO: Link to 5.6.1 book.

TODO: The reason: when we iterate through closures and use iteration variables

TODO: the fix



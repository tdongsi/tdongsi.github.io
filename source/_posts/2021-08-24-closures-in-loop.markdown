---
layout: post
title: "Closures in Loop"
date: 2021-07-24 22:12:43 -0700
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
        println("Deploy $app") 
    }
}

// DEBUG: execute the closure to debug.
for (k in deployedApps) {
    jobs[k]()
}
```

In the above code, the `jobs` variable is a mapping from String to [Groovy Closure](https://groovy-lang.org/closures.html) objects. 
It is intended for [`parallel` step](https://www.jenkins.io/doc/pipeline/steps/workflow-cps/#parallel-execute-in-parallel) to programmatically create a multi-fork stage in Jenkins.

``` groovy
// Constructing "jobs" variable as above.

stage('Deploy') {
  parallel jobs
}
```

The stage will look like this in BlueOcean interface:

{% img center /images/jenkins/parallel.png Parallel jobs %}

As you can probably guess, the intention is to concurrently deploy/print mulitple distinct applications, colorfully named as `app1` `app2` `app3`, in a Jenkins stage "Deploy".
However, it does not work, as shown in the console log output below (NOTE: the deployment code has been replaced with `println` for simplicity). 

``` plain Console log
[Pipeline] stage
[Pipeline] { (Deploy)
[Pipeline] parallel
[Pipeline] { (Branch: app1)
[Pipeline] { (Branch: app2)
[Pipeline] { (Branch: app3)
[Pipeline] echo
Deploy app3
[Pipeline] }
[Pipeline] echo
Deploy app3
[Pipeline] }
[Pipeline] echo
Deploy app3
[Pipeline] }
[Pipeline] // parallel
[Pipeline] }
[Pipeline] // stage
```

Although the keys (used for display names) are correct, the values, which are Closure objects for actual execution such as deployment or simple prints, are wrong.
The bug is subtle and puzzling: only the **last element** in the application list, regardless of its size and content, will be deployed or printed out (`app3` in this example).
As we look further into it, we'll see that this problem has nothing to do with Map or Groovy. 
It can happen to any language that has closures.
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
    for i := 0; i < 5; i++ {
        closures = append(closures, func() {
            fmt.Println(i)
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

In these List-based examples, "5" (the last values of the list) is always printed 5 times.

It turns out that this surprise problem is quite common.
In fact, it is so common that the "Go Programming Language" book dedicates [a whole section](https://www.oreilly.com/library/view/the-go-programming/9780134190570/ebook_split_047.html) (5.6.1: Caveat: Capturing iteration variables) in its Chapter 5 to discuss this gotcha.
The reason is related to scope rule: as we iterate through closures and use iteration variable (`i` in the three list examples), all the Closure objects created in this loop "capture" and share the same variable `i` (i.e., same addressable memory location) - not its value at that particular iteration (such as 0 in the first iteration).
At the end of the loop, the variable `i` has been updated several times and has the final value `5`.
Thus, the values that are used by all individual Closure objects when executed are all `5`'s instead of 0-4 for each.

Now that we understand what went wrong, the fix is pretty simple: we simply declare a new variable within the loop body before using it in the closure.
By doing so, each Closure object will have a separate variable (with distinct memory address) and value.

``` groovy Groovy fix
// Map version
def deployedApps = [ 'app1', 'app2', 'app3']
def jobs = [:]

for (String e: deployedApps) {
    def app = e  // TRICKY: necessary!
    jobs[app] = { 
        println("Deploy $app") 
    }
}

// List version
def closures = []
for (int i = 0; i < 5; i++) {
    def e = i  // TRICKY: necessary!
    closures += { println e }
}
closures.each{ it() }
```

``` go Go fix
    var closures []func()

    // Functions to Print from 0 to 4
    for i := 0; i < 5; i++ {
        e := i  // TRICKY: necessary!
        closures = append(closures, func() {
            fmt.Println(e)
        })
    }
```

``` javascript JavaScript fix
for (var i = 0; i < 5; i++) {
    let e = i;  // TRICKY: necessary!
    setTimeout(function() {
        console.log(e);
    }, 0);
}
```

In general, I would recommend adding the comment `TRICKY: necessary!`. 
This would caution another team member, out of desire for [premature optimization](https://softwareengineering.stackexchange.com/questions/80084/is-premature-optimization-really-the-root-of-all-evil), from accidentally remove the apparently useless line and produce the subtly incorrect variants as seen above.

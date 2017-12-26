---
layout: post
title: "Class in Jenkins Shared Library"
date: 2017-12-26 11:18:09 -0800
comments: true
categories: 
- Groovy
- Jenkins
---

This post reviews things to keep in mind when we implement Groovy classes and/or static Groovy methods, in `src` folder as opposed to `vars` folder, for Jenkins Shared Library.

<!--more-->

### Recommended practices

Per recommended by Jenkins documentation by CloudBees Inc., `src` folder is best for static Groovy methods.
TODO: citation needed.

### Accessing steps

Groovy classes in Shared Jenkins library cannot directly call steps such as `sh` or `git`. 
They can however implement methods, outside of the scope of an enclosing class, which in turn invoke Pipeline steps, for example:

``` groovy
// src/org/foo/Zot.groovy
package org.foo;

def checkOutFrom(repo) {
  git url: "git@github.com:jenkinsci/${repo}"
}
```

Which can then be called from a Scripted Pipeline:

``` groovy
def z = new org.foo.Zot()
z.checkOutFrom(repo)
```

This approach has limitations; for example, it prevents the declaration of a superclass.

Alternately, a set of steps can be passed explicitly using this to a library class, in a constructor, or just one method:

``` groovy
package org.foo
class Utilities implements Serializable {
  def steps
  Utilities(steps) {this.steps = steps}
  def mvn(args) {
    steps.sh "${steps.tool 'Maven'}/bin/mvn -o ${args}"
  }
}
```

When saving state on classes, such as above, the class must implement the Serializable interface. 
This ensures that a Pipeline using the class, as seen in the example below, can properly suspend and resume in Jenkins.

```
@Library('utils') import org.foo.Utilities
def utils = new Utilities(this)
node {
  utils.mvn 'clean package'
}
```

If the library needs to access global variables, such as `env`, those should be explicitly passed into the library classes, or methods, in a similar manner.

Instead of passing numerous variables from the Scripted Pipeline into a library,

``` groovy
package org.foo
class Utilities {
  static def mvn(script, args) {
    script.sh "${script.tool 'Maven'}/bin/mvn -s ${script.env.HOME}/jenkins.xml -o ${args}"
  }
}
```

The above example shows the script being passed in to one static method, invoked from a Scripted Pipeline as follows:

``` groovy
@Library('utils') import static org.foo.Utilities.*
node {
  mvn this, 'clean package'
}
```

### Reference

* [Accessing Steps section in Jenkins Doc](https://jenkins.io/doc/book/pipeline/shared-libraries/)

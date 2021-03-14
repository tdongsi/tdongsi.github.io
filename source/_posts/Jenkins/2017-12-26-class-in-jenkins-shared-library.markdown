---
layout: post
title: "`src` folder in Jenkins Shared Library"
date: 2017-12-26 11:18:09 -0800
comments: true
categories: 
- Groovy
- Jenkins
---

This post reviews best practices when we implement Groovy classes and/or static Groovy methods, in `src` folder as opposed to `vars` folder, for Jenkins Shared Library.

<!--more-->

### Examples of shared libraries in `src` folder

All Groovy files in Jenkins shared library for pipelines have to follow this directory structure:

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

`src` folder is intended to set up with `groovy` files in the standard directory structure, such as "src/org/foo/bar.groovy".
It will be added to the class path when the Jenkins pipelines are executed.

Any custom function in a Jenkins shared library has to eventually use basic Pipeline steps such as `sh` or `git`, made available through various Jenkins plugins.
However, Groovy classes in shared Jenkins library cannot simply call those basic steps directly.
There are a few approaches on how to access those Pipeline steps indirectly.

### Method 1: Methods in implicit class

Groovy scripts in `src` folder can implement methods that invoke Pipeline steps, like this:

``` groovy Example 1
// src/org/demo/buildUtils.groovy
package org.demo

def checkOutFrom(repo) {
  git url: "git@github.com:jenkinsci/${repo}"
}
```

The method is stored implicitly in library and can then be invoked from a Scripted Pipeline like this:

``` groovy Example 1 (continued)
def myUtils = new org.demo.buildUtils()
myUtils.checkOutFrom(repo)
```

However, the requirement of this approach is that those methods defined in `buildUtils.groovy` cannot be enclosed in any class.
The "implicit class" mentioned in this approach refers to the fact that any Groovy script, such as `buildUtils.groovy`, has an implicit class (e.g., `org.demo.buildUtils`) that contains all the defined functions in it.
This approach has limitations; for example, it prevents the declaration of a superclass.

### Method 2: Explicit objects

In the following example, we create an enclosing class that would facilitate things like defining a superclass.
In that case, to access standard DSL steps such as `sh` or `git`, we can explicitly pass special global variables `env` and `steps` into a constructor or a method of the class.
Global object `env` contains all current environment variables while `steps` contains all standard pipeline steps.
Note that the class must also implement Serializable interface to support saving the state if the pipeline is stopped or resumed.

``` groovy Example 2
package org.demo
class Utilities implements Serializable {
  def env
  def steps
  Utilities(env, steps) {
    this.env = env
    this.steps = steps
  }
  
  def mvn(args) {
    steps.sh "${steps.tool 'Maven'}/bin/mvn -o ${args}"
  }
}
```

``` groovy Example 2 (continued)
@Library('utils') 
import org.foo.Utilities

def utils = new Utilities(env, steps)
node {
  utils.mvn 'clean package'
}
```

### Method 3: Static methods in explicit class

In the final example, we can also use static method and pass in the `script` object, which already has access to everything, including environment variables `script.env` and Pipeline steps such as `script.sh`.

``` groovy Example 3
package org.demo
class Utilities {
  static def mvn(script, args) {
    script.sh "${script.tool 'Maven'}/bin/mvn -s ${script.env.HOME}/jenkins.xml -o ${args}"
  }
}
```

The above example shows the script being passed in to one static method, invoked from a Scripted Pipeline as follows (note `import static`):

``` groovy Example 3 (continued)
@Library('utils') 
import static org.demo.Utilities.*
node {
  mvn this, 'clean package'
}
```

### Recommended practices

All three approaches shown in three examples above are valid in Scripted Jenkinsfile.
However, per [recommended](https://youtu.be/M8U9RyL756U?list=PLvBBnHmZuNQLqgKDFmGnUClw68qsQ9Hq5&t=2310) by [CloudBees Inc.](https://www.slideshare.net/BrentLaster/2017-jenkins-world/36), `src` folder is best for utility classes that contains a bunch of static Groovy methods.
It is easier to use global variables in the `vars` directory instead of classes in the `src` directory, especially when you need to support **declarative** pipelines in your team.
The reason is that in declarative pipelines, the custom functions in Jenkins shared libraries must be callable in declarative syntax, e.g., "myCustomFunction var1, var2" format.
As you can see in the examples above, only in Method 3 (Static methods in explicit class), where custom functions are defined as static methods, the invocation of custom function is compatible with declarative pipeline syntax.

When using `src` area's Groovy codes with `library` step, you should use a temporary variable to reduce its verbosity, as follows:

``` groovy Reduce verbosity
def mvn = library('utils').org.demo.Utilities.mvn
mvn this, 'clean package'
// or 
// mvn self, 'clean package'
```

### Reference

* [Great Talk at Jenkins World 2017](https://youtu.be/M8U9RyL756U?list=PLvBBnHmZuNQLqgKDFmGnUClw68qsQ9Hq5&t=1576)
* [Accessing Steps section in Jenkins Doc](https://jenkins.io/doc/book/pipeline/shared-libraries/)

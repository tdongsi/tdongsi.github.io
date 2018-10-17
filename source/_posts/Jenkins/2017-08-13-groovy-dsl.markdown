---
layout: post
title: "DSL implementation in Groovy"
date: 2017-08-13 15:18:30 -0700
comments: true
categories: 
- Groovy
- Java
- Jenkins
---

Domain-Specific Language is a mini language for a specific problem and/or in a narrow context.
For example, internally used automation tools usually define some small DSL for configuration and most users understand the context and what DSL offers.

This blog post offers my simplistic view of how an internal DSL is implemented in Groovy via closure delegation.
It shows the progression from standard Java-like implementation -> its fluent version -> final DSL form.
This might help undrestanding the inner workings of a DSL such as Jenkins's Pipeline steps.
There are probably more advanced methods/frameworks for creating DSL. 
However, those are not in the scope of this post.

<!--more-->

### Example DSL

We want to implement a simple DSL that is similar to [Pipeline steps in Jenkinsfile](https://jenkins.io/doc/pipeline/steps/).

``` plain DSL in Jenkinsfile
{
    withEnv("PATH=/usr/bin")
    echo("Starting pipeline")
    sh("ls .")
    error("Error here")
}
```

In this DSL example, users will write a sequence of steps using a small, pre-defined set of custom statements such as `echo` and `sh` above.
For each step in the DSL, the backend classes and objects will perform some execution in the background, using the relevant context specific to the domain (e.g., Jenkins domain).
For simplicity, `println` statements will be used in the following examples.

The advantage of DSL is that the **developers** can implement the backend in some fully-featured language such as Java but the **users** don't need to know such language to use it.
Such a separation is common in DevOps and automation frameworks where the users want the flexibility of configuring based on their needs but don't want to get exposed to the implementation details (which are usually ugly and compplicated).
Instead, the **users** only need to learn the DSL to use it while still have the flexibility to do what they want.
One example can be found in data science domain where data scientists are usually more comfortable developing in R or SQL but automated deployment frameworks or tools can be in another language such as Java.

### Version 1: Java-like standard implementation

First, we show a standard implementation in Java to show how backend execution can be implemented.
In the advanced versions, the difference is only in its public interface to make it more user-friendly but the backend execution will be similar.

``` groovy Standard Java implementation
/**
 * Java code with standard implementation
 * Try to simulate some kind of DSL like Pipeline steps in Jenkins
 */
class JavaDsl {

    void echo(String message) {
        println "Echo: $message";
    }

    void sh(String script) {
        println "Shell: $script";
    }

    void error(String message) {
        println "Error here: $message";
    }

    // A more advanced DSL
    void withEnv(String var) {
        println "Using: $var";
    }

    void execute() {
        println "Executing ...";
    }

}

println "1) Standard Java implementation";
JavaDsl javaDsl = new JavaDsl();
javaDsl.withEnv("PATH=/usr/bin");
javaDsl.echo("Starting pipeline");
javaDsl.sh("ls .");
javaDsl.error("Error here");
javaDsl.execute();
println "";
```

The problem of this approach is that users have to write Java (or Groovy) code directly to use it.

### Version 2: Fluent interface with Builder pattern

``` groovy Fluent Java implementation
/**
 * Java code with Builder pattern
 * Try to simulate some kind of DSL like Pipeline steps in Jenkins
 */
class JavaBuilderDsl {

    JavaBuilderDsl echo(String message) {
        println "Echo: $message"
        return this
    }

    JavaBuilderDsl sh(String script) {
        println "Shell: $script"
        return this
    }

    JavaBuilderDsl error(String message) {
        println "Error here: $message"
        return this
    }

    // A more advanced DSL
    JavaBuilderDsl withEnv(String var) {
        println "Using: $var"
        return this
    }

    void execute() {
        println "Executing ..."
    }
}

println "2) Fluent Java implementation (Builder)"
JavaBuilderDsl builderDsl = new JavaBuilderDsl()
builderDsl.withEnv("PATH=/usr/bin")
        .echo("Starting pipeline")
        .sh("ls .")
        .error("Error here")
        .execute()
println ""
```

In this version, [the Build design pattern](https://en.wikipedia.org/wiki/Builder_pattern#Java) is used in the implementation.
As shown above, the code is much more fluent with the object name `builderDsl` not being repeated every single line.
As a result, the code is less verbose and much more user-friendly.

### Version 3: DSL with Groovy closure

``` groovy Standard Groovy implementation
/**
 * Groovy code with standard implementation
 * Try to simulate some kind of DSL like Pipeline steps in Jenkins
 */
class GroovyDsl {

    def echo(String message) {
        println "Echo: $message"
    }

    def sh(String script) {
        println "Shell: $script"
    }

    def error(String message) {
        println "Error here: $message"
    }

    // A more advanced DSL
    def withEnv(String var) {
        println "Using: $var"
    }

    static void execute(closure) {
        GroovyDsl body = new GroovyDsl()
        closure(body)
        println "Executing ..."
    }

}

println "3) Standard Groovy implementation"
GroovyDsl.execute { dsl ->
    dsl.withEnv("PATH=/usr/bin")
    dsl.echo("Starting pipeline")
    dsl.sh("ls .")
    dsl.error("Error here")
}
println ""
```

This first version of Groovy implementation is presented here to show connection with its Java counterparts.
As shown below, the input variable `dsl` in the closure can be abstracted away using delegate.

``` groovy Transparent DSL with delegate
class GroovyDsl {

    def echo(String message) {
        println "Echo: $message"
    }

    def sh(String script) {
        println "Shell: $script"
    }

    def error(String message) {
        println "Error here: $message"
    }

    // A more advanced DSL
    def withEnv(String var) {
        println "Using: $var"
    }

    static void execute(Closure closure) {
        GroovyDsl body = new GroovyDsl()
        // TRICKY: Modify the input var? Hmmm.
        closure.delegate = body
        closure()
        println "Executing ..."
    }

    static void executeBest(Closure closure) {
        GroovyDsl body = new GroovyDsl()
        body.with(closure)
        println "Executing ..."
    }

}

println "4) DSL-style Groovy implementation"
GroovyDsl.execute {
    withEnv("PATH=/usr/bin")
    echo("Starting pipeline")
    sh("ls .")
    error("Error here")
}
println ""

println "4b) DSL-style Groovy (better) implementation"
GroovyDsl.executeBest {
    withEnv("PATH=/usr/bin")
    echo("Starting pipeline")
    sh("ls .")
    error("Error here")
}
println ""
```

In this final version, only a very small boiler-plate code `GroovyDsl.executeBest` remains.
The following lines form a mini language (i.e., DSL) that can be exposed to users.
The users can start using the DSL without having to learn Groovy or Java.

Note that the `executeBest` is the equivalent but less straight-forward way to do the same thing with delegate.
Compared with `execute`, it has the benefit of NOT modifying the input reference `closure`.

### Job DSL

``` groovy Minimal Job DSL
job('Demo') {
    description("Starting pipeline")
    logRotator {
        daysToKeep(15)
    }
    steps {
        shell('echo "Hello World"')
    } 
}
```

``` groovy Simple implementation of Job DSL
class GroovyDsl {

    def description(String description) {
        print '<description>'
        print description
        println '</description>'
    }

    def logRotator(Closure inner) {
        println '<logRotator>'
        inner()
        println '</logRotator>'
    }

    def steps(Closure inner) {
        println '<builders>'
        inner()
        println '</builders>'
    }
    
    static void job(String name, Closure closure) {
        GroovyDsl body = new GroovyDsl()

        println "Generating a Freestyle job $name"
        println "Save the following into config.xml file"
        println '<project>'
        body.with(closure)
        println '</project>'
    }

}

def daysToKeep(int num) {
    println "<daysToKeep>$num</daysToKeep>"
    println '<numToKeep>-1</numToKeep>'
    println '<artifactDaysToKeep>-1</artifactDaysToKeep>'
    println '<artifactNumToKeep>-1</artifactNumToKeep>'
}

def shell(String cmd) {
    println '<hudson.tasks.Shell>'
    println '<command>'
    println cmd
    println '</command>'
    println '</hudson.tasks.Shell>'
}

GroovyDsl.job('Demo') {
    description("Starting pipeline")
    logRotator {
        daysToKeep(15)
    }
    steps {
        shell('echo "Hello World"')
    } 
}
```

``` xml Output of the above script
Generating a Freestyle job Demo
Save the following into config.xml file
<project>
<description>Starting pipeline</description>
<logRotator>
<daysToKeep>15</daysToKeep>
<numToKeep>-1</numToKeep>
<artifactDaysToKeep>-1</artifactDaysToKeep>
<artifactNumToKeep>-1</artifactNumToKeep>
</logRotator>
<builders>
<hudson.tasks.Shell>
<command>
echo "Hello World"
</command>
</hudson.tasks.Shell>
</builders>
</project>
```

Compared with the Jenkins config.xml of the Freestyle job generated by the same Job DSL, we can see that there is not much different. 

``` xml Output of config.xml in Jenkins
<project>
<actions/>
<description>Starting pipeline</description>
<keepDependencies>false</keepDependencies>
<properties/>
<scm class="hudson.scm.NullSCM"/>
<canRoam>true</canRoam>
<disabled>false</disabled>
<blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
<blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
<triggers/>
<concurrentBuild>false</concurrentBuild>
<builders>
<hudson.tasks.Shell>
<command>echo "Hello World"</command>
</hudson.tasks.Shell>
</builders>
<publishers/>
<buildWrappers/>
<logRotator>
<daysToKeep>15</daysToKeep>
<numToKeep>-1</numToKeep>
<artifactDaysToKeep>-1</artifactDaysToKeep>
<artifactNumToKeep>-1</artifactNumToKeep>
</logRotator>
</project>
```

### Reference

* [Groovy closure](http://groovy-lang.org/closures.html)
* [Jenkins pipeline steps](https://jenkins.io/doc/pipeline/steps/)
* [Another example Groovy implementation](https://dzone.com/articles/groovy-dsl-simple-example)
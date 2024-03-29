---
layout: post
title: "IntelliJ setup for Jenkins development"
date: 2018-02-09 22:32:59 -0700
comments: true
featured: true
categories: 
- Jenkins
- Groovy
- Java
- Gradle
---

This posts will show how to setup IntelliJ for development of Jenkins [Groovy Init Scripts](/blog/2017/12/30/groovy-hook-script-and-jenkins-configuration-as-code/) and [shared libraries](https://jenkins.io/doc/book/pipeline/shared-libraries/), including auto-complete for [Jenkins pipeline steps](https://jenkins.io/doc/pipeline/steps/).
This is based on my original write-up in [this project](https://github.com/tdongsi/jenkins-config/blob/develop/docs/IDE.md).

<!--more-->

NOTE: this setup is NOT intended for Jenkins plugin or core development.

### Start a new Gradle project

It is best to start a new project:

1. Select **File | New Project**
1. Select **Gradle**
1. Select **Java** AND **Groovy**
![Screeshot](/images/idea/screen01.png "Start")
1. Choose **GroupId** and **ArtifactId**
![Screeshot](/images/idea/screen02.png "Project Name")
1. Enter path to Gradle. For Gradle on Mac installed via Homebrew, the Gradle home is like this:
![Screeshot](/images/idea/screen03.png "Configure Gradle")
   NOTE: For Gradle installed on a Mac via Homebrew, the path "/usr/local/opt/gradle/libexec" may be preferrable to "/usr/local/Cellar/gradle/X.X/libexec" since the former will stay the same after Gradle version upgrades.
   In addition, if you work extensively with Grails/Gradle/Groovy, you may prefer installing via [`sdk` tool](https://sdkman.io/install) instead of Homebrew.
1. Choose **Project name** and **Project Location**
![Screeshot](/images/idea/screen04.png "Project location")
1. Finish
![Screeshot](/images/idea/screen05.png "Finish")

### Configure IDEA

Set up for Jenkins Plugins files which are of types **.hpi** or **.jpi**.

1. Select **IntelliJ IDEA | Preferences | Editor | File Types**
1. Select **Archive**
1. Select **+** at the bottom left corner
1. Add both **.hpi** and **.jpi**
1. Select **OK**

![Screeshot](/images/idea/screen06.png "Configure plugin files")

Modify **build.gradle** to add the following lines.

```groovy
    compile 'org.jenkins-ci.main:jenkins-core:2.23'

    // Jenkins plugins
    compile group: 'org.jenkins-ci.plugins', name: 'credentials', version: '2.1.13', ext: 'jar'
    compile group: 'org.jenkins-ci.plugins', name: 'matrix-auth', version: '1.6', ext: 'jar'
    compile group: 'org.jenkins-ci.plugins.workflow', name: 'workflow-cps', version: '2.39', ext: 'jar'

    // TRICKY: The lib folder contains all other plugins *JAR* files
    // if not found in Maven
    compile fileTree(dir: 'lib', include: ['*.jar'])
```

The above example will grab Jenkins core libraries, Matrix Authorization Plugin hpi, other plugin dependencies and javadocs for all imported libraries.
Having these libraries imported will enable code auto-completion, syntax checks, easy refactoring when working with Groovy scripts for Jenkins.
It will be a great productivity boost.

NOTE 1: The last line `compile fileTree` is the last resort for any Jenkins plugins that you cannot find the right group ID and artifact ID.
It is rare these days but such cases cannot be completely ruled out.

NOTE 2: The `ext: 'jar'` is VERY important to ensure that `jar` files, instead of `hpi`/`jpi` files, are being downloaded and understood by IntellJ.
Without that `ext` option specified, IntellJ won't find JAR files nested in `hpi`/`jpi` files which is the default binaries for Jenkins plugins.

The final **build.gradle** will look like [this](https://github.com/tdongsi/jenkins-steps-override/blob/master/build.gradle).
All of the above setup should suffice for working with [Groovy Init Scripts](http://tdongsi.github.io/blog/2017/12/30/groovy-hook-script-and-jenkins-configuration-as-code/).
For working with Jenkins Shared Pipeline Libraries, we should take one extra step shown as follows. 

### Setup for Jenkins pipeline library

All Groovy files in Jenkins shared library for Pipelines have to follow this directory structure:

```text Directory structure of a Shared Library repository
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

Note that the Groovy code can be in both [`src`](http://tdongsi.github.io/blog/2017/12/26/class-in-jenkins-shared-library/)
and [`vars`](http://tdongsi.github.io/blog/2017/03/17/jenkins-pipeline-shared-libraries/) folders.
Therefore, you need to add the following lines in `build.gradle` to inform Gradle locations of Groovy source codes:

```groovy
sourceSets {
    main {
        groovy {
            srcDirs = ['vars', 'src']
        }
    }

    test {
        groovy {
            srcDirs = ['test']
        }
    }
}
```

Optionally, for unit testing Jenkins shared library, we have to add the following dependencies into our **build.gradle** file.

``` groovy
    testCompile group: 'com.lesfurets', name: 'jenkins-pipeline-unit', version: '1.1'
    testCompile group: 'org.spockframework', name: 'spock-core', version: '1.1-groovy-2.4'
```

Please see [this blog post](/blog/2018/06/07/jenkins-pipeline-unit-testing/) for more details on unit testing.
The final **build.gradle** will look like [this](https://github.com/tdongsi/jenkins-steps-override/blob/master/build.gradle).

#### Auto-completion for Jenkins Pipeline

IntelliJ can't auto-complete [Jenkins pipeline steps](https://jenkins.io/doc/pipeline/steps/) such as `echo` or `sh` out of the box.
We have to make it aware of those Jenkins pipeline DSLs, via a generic process explained [here](https://confluence.jetbrains.com/display/GRVY/Scripting+IDE+for+DSL+awareness).
Fortunately, it is much easier than it looks and you don't have to actually write GroovyDSL script for tens of Jenkins pipeline steps.
Jenkins make it easy by auto-generating the GroovyDSL script and it is accessible via "IntelliJ IDEA GDSL" link, as shown in screenshot below.

![Screeshot](/images/idea/screen08.png "GroovyDSL")

The "IntelliJ IDEA GDSL" link can be found by accessing "Pipeline Syntax" section, which is visible in the left navigation menu of any Pipeline-based job (e.g., "Admin" job in the example above).
After clicking on the "IntelliJ IDEA GDSL" link, you will be able to download a plain text file with content starting like this:

``` groovy IntelliJ IDEA GDSL
//The global script scope
def ctx = context(scope: scriptScope())
contributor(ctx) {
method(name: 'build', type: 'Object', params: [job:'java.lang.String'], doc: 'Build a job')
method(name: 'build', type: 'Object', namedParams: [parameter(name: 'job', type: 'java.lang.String'), parameter(name: 'parameters', type: 'Map'), parameter(name: 'propagate', type: 'boolean'), parameter(name: 'quietPeriod', type: 'java.lang.Integer'), parameter(name: 'wait', type: 'boolean'), ], doc: 'Build a job')
method(name: 'echo', type: 'Object', params: [message:'java.lang.String'], doc: 'Print Message')
method(name: 'error', type: 'Object', params: [message:'java.lang.String'], doc: 'Error signal')
...
```

As you can see, it is a GroovyDSL file that describes the known pipeline steps such as `echo` and `error`.
Note that GDSL files can be different for different Jenkins instances, depending on Pipeline-supported plugins currently installed on individual Jenkins instance.
To make IntelliJ aware of the current Jenkins pipeline steps available on our Jenkins, we need to place that GDSL file into a location known to source folders.
As shown in the last section, anywhere in both `vars` and `src` folders are eligible as such although I personally prefer to put the GDSL file into `vars` folder ([for example](https://github.com/tdongsi/jenkins-steps-override/tree/master/vars)).

After installing the GDSL file into a proper location, IntelliJ may complain with the following message *DSL descriptor file has been change and isn’t currently executed* and you have to click **Activate back** to get the IntelliJ aware of the current DSLs.
After that, you can enjoy auto-completion as well as documentation of the Jenkine Pipeline DSLs.

### More information

* [Example of final setup](https://github.com/tdongsi/jenkins-steps-override)

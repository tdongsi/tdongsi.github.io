---
layout: post
title: "Troubleshooting Groovy code in Jenkinsfile"
date: 2017-06-16 23:52:44 -0700
comments: true
categories: 
- Groovy
- Jenkins
---

In this post, we look into some troubleshooting tips when [using independent Groovy scripts in Jenkins pipeline](/blog/2017/04/18/groovy-code-in-jenkins-pipeline/).

### Named parameters not supported

**Problem**: Named parameters in Groovy is apparently not supported in Jenkinsfile:

``` groovy Named parameters
// This does NOT work
def bodyText = code.getPrBody(githubUsername: env.GITHUB_USERNAME, githubToken: env.GITHUB_PASSWORD, repo: 'Groovy4Jenkins', id: env.CHANGE_ID)

// This works
def bodyText = code.getPrBody(env.GITHUB_USERNAME, env.GITHUB_PASSWORD, 'Groovy4Jenkins', env.CHANGE_ID)
```

We get the following error message when using named parameters:

``` plain Error message
java.lang.NoSuchMethodError: No such DSL method 'getPrBody' found among steps 
[archive, bat, build, catchError, checkout, deleteDir, dir, echo, emailext, emailextrecipients, ...
```

**Workaround**: Avoid using named parameters in calling methods.

### Cannot load a Groovy script in Declarative Pipeline

**Problem**: Loading Groovy methods from a file with `load` step does not work inside Declarative Pipeline step, as reported in [this issue](https://issues.jenkins-ci.org/browse/JENKINS-43455).

**Workaround**: There are a few work-arounds. The most straight-forward one is to use [`script` step](https://jenkins.io/doc/book/pipeline/syntax/#declarative-pipeline).

``` groovy Loading Groovy script
    steps {
        checkout scm
        withCredentials([
            [$class: 'StringBinding', credentialsId: 'nexusUserName', variable: 'nexusUserName'],
            [$class: 'StringBinding', credentialsId: 'nexusPassword', variable: 'nexusPassword']
        ]) {
            script {
                myScript = load 'jenkins/xml.groovy'
                String myPath = myScript.transformXml(settingsFile, env.nexusUserName, env.nexusPassword)
                sh "mvn -B -s ${myPath} clean compile"
            
                sh "rm ${myPath}"
            }
        }
    }
```

 You can also define Groovy methods from inside the Jenkinsfile.

``` groovy Example Jenkinsfile
import groovy.xml.StreamingMarkupBuilder
import groovy.xml.XmlUtil

@NonCPS
def xmlTransform(txt, username, password) {
    
    def xmlRoot = new XmlSlurper(false, false).parseText(txt)
    echo 'Start tranforming XML'
    xmlRoot.servers.server.each { node ->
       node.username = username
       node.password = password
    }

    // TRICKY: FileWriter does NOT work
    def outWriter = new StringWriter()
    XmlUtil.serialize( xmlRoot, outWriter )
    return outWriter.toString()
}

...

   steps {
        checkout scm
        withCredentials([
            [$class: 'StringBinding', credentialsId: 'nexusUserName', variable: 'nexusUserName'],
            [$class: 'StringBinding', credentialsId: 'nexusPassword', variable: 'nexusPassword']
        ]) {
            script {
                myScript = load 'jenkins/xml.groovy'
                String myPath = xmlTransform(settingsFile, env.nexusUserName, env.nexusPassword)
                sh "mvn -B -s ${myPath} clean compile"
            
                sh "rm ${myPath}"
            }
        }
    }
```

For Declarative Pipeline, to reuse the code from a Groovy script, you must use Shared Libraries.
Shared Libraries are not specific to Declarative; they were released some time ago and were seen in Scripted Pipeline.
[This blog post](/blog/2017/03/17/jenkins-pipeline-shared-libraries/) discusses an older mechanism for Shared Library.
For the newer mechanism of importing library, please check out [this blog post](https://jenkins.io/blog/2017/02/15/declarative-notifications/).
Due to Declarative Pipeline’s lack of support for defining methods, Shared Libraries definitely take on a vital role for code-reuse in Jenkinsfile.

### `File` reading and writing not supported

Java/Grooy reading and writing using "java.io.File" class is not directly supported.

``` groovy Using File class does NOT work
def myFile = new File('/home/data/myfile.xml')
```

In fact, using that class in Jenkinsfile must go through "In-Process Script Approval" with this warning.

{% blockquote %}
new java.io.File java.lang.String Approving this signature may introduce a security vulnerability! You are advised to deny it.
{% endblockquote %}

Even then, "java.io.File" will refer to **files on the master** (where Jenkins is running), not the current workspace on Jenkins slave (or slave container).
As a result, it will report the following error even though the file is present in filesystem ([relevant Stackoverflow](https://stackoverflow.com/questions/41739468/groovy-reports-that-a-file-doesnt-exists-when-it-really-is-present-in-the-syste)) on slave:

``` plain
java.io.FileNotFoundException: /home/data/myfile.xml (No such file or directory)
	at java.io.FileInputStream.open0(Native Method)
```

That also means related class such as FileWriter will NOT work as expected. 
It reports no error during execution but you will find no file since those files are created on Jenkins master.

**Workaround**: 

* For file reading, use [`readFile` step](https://jenkins.io/doc/pipeline/steps/workflow-basic-steps/#readfile-read-file-from-workspace).
* For file writing, use `writeFile` step. However, Pipeline steps (such as `writeFile`) are NOT allowed in `@NonCPS` methods. For more complex file writing, you might want to export the file content as String and use the following code snippet:

``` groovy Shell command
    String xmlFile = ...

    // TRICKY: FileWriter does NOT work in xmlTransform
    def mCommand = "cat >${settingsFile} <<EOF"
    mCommand += "\n${xmlFile}\nEOF"
    sh mCommand
```

In the code snippet above, we construct a [*here document*-formatted](https://en.wikipedia.org/wiki/Here_document#Unix_shells) command for writing multi-line string in `mCommand` before passing to `sh` step for executing.

``` plain heredoc example to explain mCommand
$ cat >output.txt <<EOF
SELECT foo, bar FROM db
WHERE foo='baz'
More line from xmlFile
EOF

$ cat output.txt
SELECT foo, bar FROM db
WHERE foo='baz'
More line from xmlFile
```

### Serialization errors

You often encounter this type of errors when using non-serialiable classes from Groovy/Java libraries.

``` plain Error in Jenkins log
java.io.NotSerializableException: org.codehaus.groovy.control.ErrorCollector
	at org.jboss.marshalling.river.RiverMarshaller.doWriteObject(RiverMarshaller.java:860)
```

``` plain Related error in Jenkins log
java.lang.UnsupportedOperationException: Calling public static java.lang.Iterable 
org.codehaus.groovy.runtime.DefaultGroovyMethods.each(java.lang.Iterable,groovy.lang.Closure) on a
CPS-transformed closure is not yet supported (JENKINS-26481); 
encapsulate in a @NonCPS method, or use Java-style loops
	at org.jenkinsci.plugins.workflow.cps.GroovyClassLoaderWhitelist.checkJenkins26481
    (GroovyClassLoaderWhitelist.java:90)
```

There is also some known [issue about JsonSlurper](https://issues.jenkins-ci.org/browse/JENKINS-35140).
These problems come from the fact that variables in Jenkins pipelines must be serializable.
Since pipeline must survive a Jenkins restart, the state of the running program is periodically saved to disk for possible resume later.
Any "live" objects such as a network connection is not serializble.

**Workaround**: 
Explicitly discard non-serializable objects or use [@NonCPS](https://support.cloudbees.com/hc/en-us/articles/230612967-Pipeline-The-pipeline-even-if-successful-ends-with-java-io-NotSerializableException) methods.

Quoted from [here](https://github.com/jenkinsci/workflow-cps-plugin/blob/master/README.md): `@NonCPS` methods may safely use non-`Serializable` objects as local variables, though they should NOT accept nonserializable parameters or return or store nonserializable values.
You may NOT call regular (CPS-transformed) methods, or Pipeline steps, from a `@NonCPS` method, so they are best used for performing some calculations before passing a summary back to the main script.

### References

* [Declarative syntax](https://jenkins.io/doc/book/pipeline/syntax/#declarative-pipeline)
* [Shared Libraries for Declarative Pipeline](https://jenkins.io/blog/2017/02/15/declarative-notifications/)
* Here document
  * [Theory](https://en.wikipedia.org/wiki/Here_document#Unix_shells)
  * [Common usage from Stackoverflow](https://stackoverflow.com/questions/2500436/how-does-cat-eof-work-in-bash)
  * [Heredoc with and without variable expansion](http://www.guguncube.com/2140/unix-set-a-multi-line-text-to-a-string-variable-or-file-in-bash)

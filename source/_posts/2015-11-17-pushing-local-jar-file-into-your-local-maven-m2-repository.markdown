---
layout: post
title: "Pushing local jar file into your local Maven (m2) repository"
date: 2015-11-17 16:46:49 -0800
comments: true
categories:
- Database
- Vertica
- JDBC
- Maven
- Eclipse
- Java
---

#### Problem:
I want to use Vertica JDBC driver in my Eclipse Maven project. I have the jar file from the vendor (i.e, downloaded from HP-Vertica support website) but, obviously, that file is not in Maven central repository. My Maven build will not work without that dependency. 

This post will also apply if you are behind a firewall and/or do not have external access for some reason.
#### Solution:

* Download the jar file (e.g., the Vertica JDBC jar file). 
* At the same directory as the jar file, run the following command to install the jar to the local Maven repository (running in a different directory seems not work).

``` bash General Maven command
$ mvn install:install-file -DgroupId=<GROUP_ID> -DartifactId=<ARTIFACT_ID> -Dversion=<VERSION> -Dpackaging=jar -Dfile=<LOCAL_PATH_FOR_JAR> -DgeneratePom=true
```

Example:

``` bash Example Maven command for Vertica JDBC
$ mvn install:install-file -DgroupId=vertica -DartifactId=vertica-jdbc -Dversion=7.0.1 -Dpackaging=jar -Dfile=~/Downloads/vertica/vertica-jdbc-7.0.1.jar -DgeneratePom=true
```

* Now when you run your maven goals, it will not look for this particular jar file in any external repository such as Maven Central Repository since Maven checks and perceives that it is already in your local repository (your ~/.m2 directory).

If you want your Eclipse to start using this jar from your local repository:

* In Eclipse Luna on a Mac/Windows, go to Navigate > Show View > Other > Maven > Maven Repository.
* Open Local Repositories > Local Repository.
* Right click for the context menu > Rebuild Index.

Now it should show up in “Add…” dialog in pom.xml edit. 
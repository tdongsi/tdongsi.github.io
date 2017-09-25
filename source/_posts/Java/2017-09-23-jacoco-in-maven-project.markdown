---
layout: post
title: "Jacoco in Maven projects"
date: 2017-09-23 21:39:13 -0700
comments: true
categories: 
- Java
- Jacoco
- Maven
---

This blog post goes over some recipes for adding code coverage report to Maven-based projects with Jacoco.

<!--more-->

### Typical usage

Based on [offical instruction](http://www.eclemma.org/jacoco/trunk/doc/maven.html) and [this](https://stackoverflow.com/questions/36199422/maven-unit-test-code-coverage), you need to add the following code snippet in to your Maven `pom.xml`.

``` xml Jacoco usage (typical Maven project)
<project>
...

    <dependencies>
        ...
    </dependencies>

    <build>
        <plugins>
            ...
            <!-- Code Coverage report generation -->
            <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>0.7.9</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>prepare-agent</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>generate-code-coverage-report</id>
                        <phase>test</phase>
                        <goals>
                            <goal>report</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
```

At least, you need "prepare-agent" before test phase for Jacoco instrumentation and "report" after test phase for generating the report.
You could subject the project to code coverage and generate the same report without making any changes to the pom file. 
To do this, run the following command:

``` plain Jacoco from Maven command-line
mvn jacoco:prepare-agent test jacoco:report
```

You may get the following error:

``` plain
[ERROR] No plugin found for prefix 'jacoco' in the current project ...
```

There are two options to fix that error. 
The easiest way is to specify the `groupId` and `artifactId` parameters of the plugin explicitly.
You can also add `version` to ensure the stability of your build pipeline.

``` plain
mvn clean org.jacoco:jacoco-maven-plugin:0.7.9:prepare-agent install org.jacoco:jacoco-maven-plugin:0.7.9:report
```

The more long-term solution is to add the following in to your Maven "settings.xml".

``` xml Maven settings
<pluginGroups>
    <pluginGroup>org.jacoco</pluginGroup>
</pluginGroups>
```

### Tests with Mock

If mocking is involved in unit tests, you need to use “instrument” and “restore-instrumented” steps.

Reference:

* [PowerMock instruction](https://github.com/powermock/powermock/wiki/Code-coverage-with-JaCoCo)
* [PowerMock example pom.xml](https://github.com/powermock/powermock-examples-maven/blob/master/jacoco-offline/pom.xml)

### Multi-module Maven projects

Officially, multi-module Maven projects are supported differently by Jacoco as documented [here](https://github.com/jacoco/jacoco/wiki/MavenMultiModule).
Instrumentation will be similar but the challenge of multi-module Maven projects lies in how to collect and report code coverage of all modules correctly.
Jacoco Maven standard goals, as shown in sections above, work on single modules only: Tests are executed within the module and contributed coverage only to code within the same module.
Coverage reports were created for each module separately.

In the past, there are some ad-hoc solutions such as [this](https://dzone.com/articles/jacoco-maven-multi-module) (for Jacoco 0.5.x) to work around that limit.
However, those patterns are also error-prone and hard to customize, especially when Jacoco is used with Surefire plugin.
Fortunately, Jacoco recently introduced a new Maven goal "report-aggregate" in its release 0.7.7 which will aggregate code coverage data across Maven modules.
Its usage is also present in the same [link](https://github.com/jacoco/jacoco/wiki/MavenMultiModule) (quoted below) but it is too succint and not very helpful for new users.

{% blockquote %}
Create a dedicated module in your project for generation of the report. This module should depend on all or some other modules in the project.
{% endblockquote %}

Let' say you have a multi-module Maven project with this structure:

``` plain Multi-module Maven project
root pom
  |- module a
  |- module b
  |- module c
```

To use Jacoco "report-aggregate" goal for these modules, you first need to add a dedicated "coverage" module.
This "coverage" module should be added into the root POM.
The multi-module Maven project should now look like this:

``` plain Multi-module Maven project with aggregate coverage module
root pom
  |- module a
  |- module b
  |- module c
  |- module "coverage"
```

The POMs for each module does not need to change at all.
The POM for the "coverage" module will look like this:

``` xml Maven pom.xml for coverage module
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <parent>
        <groupId>com.company</groupId>
        <artifactId>company-pom</artifactId>
        <version>3.0</version>
    </parent>
    
    <artifactId>report</artifactId>
    <name>Jacoco Report</name>
    
    <dependencies>
        <dependency>
            <groupId>my.example</groupId>
            <artifactId>module-a</artifactId>
            <version>210.0.00-SNAPSHOT</version>
        </dependency>
        <dependency>
            <groupId>my.example</groupId>
            <artifactId>module-b</artifactId>
            <version>210.0.00-SNAPSHOT</version>
        </dependency>
        <dependency>
            <groupId>my.example</groupId>
            <artifactId>module-c</artifactId>
            <version>210.0.00-SNAPSHOT</version>
        </dependency>
    </dependencies>
    <build>
        <plugins>
            <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>0.7.9</version>
                <configuration>
                    <excludes>
                        <!-- Example of excluding classes 
                        <exclude>**/com/salesforce/iot/ingestion/config/AutoConfiguration.class</exclude>
                        -->
                    </excludes>
                </configuration>
                <executions>
                    <execution>
                        <id>report-aggregate</id>
                        <phase>verify</phase>
                        <goals>
                            <goal>report-aggregate</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>

            <!-- This coverage module should never be deployed -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-deploy-plugin</artifactId>
                <configuration>
                    <skip>true</skip>
                </configuration>
            </plugin>
        </plugins>
    </build>
</project>

```

Links:

* [Example of report-aggregate](https://stackoverflow.com/questions/13031219/how-to-configure-multi-module-maven-sonar-jacoco-to-give-merged-coverage-rep/37871210#37871210)
* [Example Maven project](https://github.com/jacoco/jacoco/tree/master/jacoco-maven-plugin.test/it/it-report-aggregate)

### References

* [Jacoco Maven plugin](http://www.jacoco.org/jacoco/trunk/doc/maven.html): there are example POMs.

<!--
* [Cross-module reporting](https://stackoverflow.com/questions/41885772/jacoco-simple-integration-test-solution/41901853#41901853)
-->
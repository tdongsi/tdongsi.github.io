---
layout: post
title: "Jacoco in Maven project"
date: 2017-09-23 21:39:13 -0700
comments: true
categories: 
- Java
- Jacoco
---

### Typical usage

Based on [offical instruction](http://www.eclemma.org/jacoco/trunk/doc/maven.html) and [this](https://stackoverflow.com/questions/36199422/maven-unit-test-code-coverage). 

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

At least, you need "prepare-agent" for Jacoco instrumentation and "report" for generating the report.

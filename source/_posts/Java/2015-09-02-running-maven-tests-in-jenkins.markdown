---
layout: post
title: "Running Maven tests in Jenkins"
date: 2015-09-03 01:10:36 -0700
comments: true
published: true
categories: 
- Maven
- Jenkins
- TestNG
---

A few notes on executing Maven + TestNG tests in Jenkins.

<!--more-->

### Running tests

Use the following Maven commands in Jenkins when executing tests.

``` plain Running tests
mvn -f pom.xml clean test
```

In pom.xml, the test suite file should be specified, such as testng.xml.
To run a custom TestNG test suite file, use the following command:

``` plain Custom TestNG test suite
mvn clean test -DsuiteXmlFile=testng.xml
```

To run a specific TestNG class, use the following command:

``` plain Run specific TestNG class/method
mvn clean test -Dtest=TestCircle

mvn clean test -Dtest=TestCircle#test_area
```

Note that the symbol `#` must be used between class name and method name. 
In other words, `-Dtest=TestCircle.test_area` will not work.

#### Links

1. [Custom TestNG suite file](http://www.vazzolla.com/2013/03/how-to-select-which-testng-suites-to-run-in-maven-surefire-plugin/)
1. [Select method in test class](http://stackoverflow.com/questions/1873995/run-a-single-test-method-with-maven)

### Configuring tests

Sometimes, your tests need to access resources outside of standard Eclipse/Maven project folders. 
For the tests to pass both locally and on Jenkins, the full path to the current workspace may be required to resolve the file path to those resources in tests. 
Jenkins set a number of [environment variables](https://wiki.jenkins-ci.org/display/JENKINS/Building+a+software+project), including the variable 
`WORKSPACE` as the absolute path of the workspace.

For local environment, we need to set environment variable `WORKSPACE` to simulate Jenkins environment.
In the tests, we need to retrieve this environment variable, as follows in Java:

``` java Getting environment variable
String wsPath = System.getenv("WORKSPACE");
```

Besides workspace's absolute path, we might also need to configure some constants in tests from a configuration file. 
When initializing constants from properties files in Maven, remember:

* Use `this.class.getResourceAsStream()` method.
* By Maven convention, properties file should be in `src/main/resources` folder.
* Default property values could be used when reading properties file.

``` java Example
    public static final String CONFIG_PATH = "/config.properties";

    static {
        Properties prop = new Properties();
        try ( InputStream stream = VerticaConnection.class.getResourceAsStream(MyConstants.CONFIG_PATH) ) {
            prop.load(stream);

            // Set values from config file with default values
            UNIT_TEST_SCHEMA = prop.getProperty("schema", "UNIT_TEST");
            FUNC_TEST_SCHEMA = prop.getProperty("schema", "FUNC_TEST");
            VSQL_PATH = prop.getProperty("vsql_path", "/opt/vertica/bin/vsql");

        } catch (FileNotFoundException e) {
            System.err.println("Cannot find file " + MyConstants.CONFIG_PATH);
            throw new IllegalStateException("Could not init class VerticaConnection.", e);
        } catch (IOException e) {
            System.err.println("Error reading file " + MyConstants.CONFIG_PATH);
            throw new IllegalStateException("Could not init class VerticaConnection.", e);
        }
    }
```

Note that the location of the properties file in the example above is `src/main/resources/config.properties`.
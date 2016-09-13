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

This blog post discusses a few tips on executing Maven + TestNG tests in Jenkins.

### Running tests

``` plain Running
tdongsi$ mvn -f tests/datamart-qe/pom.xml clean test
```

In pom.xml, the test suite file is specified as testng.xml.
To run a custom TestNG test suite file, use the following command:

``` plain Custom TestNG test suite
tdongsi$ mvn clean test -DsuiteXmlFile=testng.xml
```

To run a specific TestNG class, use the following command:

``` plain Run specific TestNG class/method
tdongsi$ mvn clean test -Dtest=TestCircle

tdongsi$ mvn clean test -Dtest=TestCircle#test_area
```

Note that the symbol `#` must be used between class name and method name. 
In other words, `-Dtest=TestCircle.test_area` will not work.

### Configuring tests

https://wiki.jenkins-ci.org/display/JENKINS/Building+a+software+project
Jenkins set the following variable:
WORKSPACE: The absolute path of the workspace.

I need to set environment variable to simulate Jenkins environment.
In Mac:
For terminal: http://stackoverflow.com/questions/7501678/set-environment-variables-on-mac-os-x-lion
For windowed application: http://stackoverflow.com/questions/135688/setting-environment-variables-in-os-x/588442#588442

Getting environment variable in Java:
https://docs.oracle.com/javase/tutorial/essential/environment/env.html
Map<String, String> env = System.getenv();




To initialize constants from properties files in Maven:

* Use `this.class.getResourceAsStream()`
* Properties file should be in `src/main/resources` folder.
* Should set default property values.

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

Note the location of the properties file.

### Links

1. [Custom TestNG suite file](http://www.vazzolla.com/2013/03/how-to-select-which-testng-suites-to-run-in-maven-surefire-plugin/)
1. [Select method in test class](http://stackoverflow.com/questions/1873995/run-a-single-test-method-with-maven)
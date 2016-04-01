---
layout: post
title: "Unit Tests Pass on Local but Fail on CI"
date: 2016-05-01 17:51:13 -0700
comments: true
categories: 
- Java
- Testing
- Jenkins
- TestNG
- JMockit
- Eclipse
---

We have all seen it before: intermittent unit test failures.
It could be agonizing that unit tests pass locally, but then fail in the Jenkins unit test build.

One of the most common causes is:
**Class static initialization code that dynamically sets a static member variable from a config file value.**

What happens locally?
If you’re running from command line, you probably have some environment variables set. 
These allow the ConfigHelper class to find the resource properties files and load them. In the end, code that looks like the following ends up succeeding:

``` java DbQueue class
private static final String MY_CONFIG = ConfigHelper.getBoolean("config_key", false);
```

But the unit test on the CI server run without being set up for a Tomcat application server run, using some mock framework.
That’s a desirable good thing.
But it means that code like that ends up failing to find those resources.
And often throwing an exception, especially when trying to load and convert a numeric value from a resource.

So, how do you fix it?
How do you keep that class static member initialization from being invoked? 
When you mock the class in JMockit using the `@Mocked` notation, you provide the `stubOutClassInitialization=true`  parameter, like this:

``` java Mock with JMockit
public class MyTest {
    @Mocked( stubOutClassInitialization = true)
    DbQueue queue;
    
    ...
}
```

That prevents the class static code that would otherwise be invoked **even though the class itself has been mocked out**.
The measure of having done this correctly and completely is that you’ll now be able to run your unit tests from inside Eclipse WITHOUT setting the `–DSBNHOME=` environment variable – and the test will still complete as desired.
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
---

We’ve all seen it.  Intermittent unit test failures.  Unit tests that pass locally, but then fail in the CI UNIT TEST build.

I’ve isolated one common cause, and likely the most common single cause:

Class static initialization code that dynamically sets a static member variable from a config file value.

What happens locally?
If you’re running from command line, you have some environment variables set.  These allow the ConfigHelper class to find the resource properties files and load them.
If you’re running in eclipse, you typically set `-DSBNHome=/…/trunk/rt`  which has the same effect.

In the end, code that looks like the following ends up succeeding:

``` java DbQueue class
private static final String MY_CONFIG = ConfigHelper.getBoolean("config.key", false);
```

But the unit test on the CI server run without being set up for a Tomcat app server run.  That’s a desirable good thing.  But it means that code like that ends up failing to find those resources.  And often throwing an exception, especially when trying to load a numeric value from a resource.

So, how do you fix it?  How do you keep that class static member initialization from being invoked? Well, when you mock the class in JMockit using the @Mocked notation, you provide the stubOutClassInitialization=true  parameter, like this:

``` java Mock with JMockit
public class MyTest {
    @Mocked( stubOutClassInitialization = true)
    DbQueue queue;
    
    ...
}
```

That prevents the class static code that would otherwise be invoked **even though the class itself has been mocked out**.

The measure of having done this correctly and completely is that you’ll now be able to run your unit tests from inside eclipse WITHOUT setting the `–DSBNHOME=` environment variable – and the test will still complete as desired.

Happy mocking.
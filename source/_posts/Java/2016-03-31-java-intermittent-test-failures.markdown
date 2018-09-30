---
layout: post
title: "Unit Tests Pass on Local but Fail on CI"
date: 2016-06-30 17:51:13 -0700
comments: true
published: true
categories: 
- Java
- Testing
- Jenkins
- TestNG
---

We have all seen it before: intermittent unit test failures.
It could be agonizing that unit tests pass locally, but then fail in the Jenkins unit test build.

<!--more-->

In our experience, one of the most common causes is:
**static initialization code that dynamically sets a static member variable from a config file value.**

What happens locally?
If you’re running from the command line, you probably have some environment variables set. 
These allow some ConfigHelper class to find the resource properties files and load them. 
In the end, code that looks like the following often ends up succeeding:

``` java DbQueue class
private static final String MY_CONFIG = ConfigHelper.getBoolean("config_key", false);
```

But the unit tests on the CI server run without being set up for a Tomcat application server run. 
Instead, they run using some mock framework such as JMockit.
Mocking in this scenario is a good, desirable thing.
However, it also means that code like that ends up failing to find those resources.
In the example above, the class `DbQueue`'s static code was invoked **even though the class itself has been mocked out**.
And very often, classes like that throw some misleading exceptions, especially when trying to load and convert to a numeric value from a resource.

So, how do we fix it?
How do we prevent that class static member initialization code from being invoked in Jenkins test build? 
The answer is when we mock the class in JMockit using the `@Mocked` annotation, we can provide the `stubOutClassInitialization=true` parameter, like this:

``` java Mock with JMockit
public class MyTest {
    @Mocked( stubOutClassInitialization = true )
    DbQueue queue;
    
    ...
}
```

That will prevent the static code in the class `DbQueue` from running in Jenkins unit test builds.
The additional benefit of doing this *correctly* and *completely* is that we’ll be able to run our unit tests from inside Eclipse WITHOUT setting the `–DSBNHOME=` environment variable and the test will still complete as desired.
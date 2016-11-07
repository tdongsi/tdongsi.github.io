---
layout: post
title: "Convert Python objects to JSON (ordered keys)"
date: 2016-05-25 01:26:22 -0700
comments: true
categories: 
- Python
---

In the JSON output shown in the last [post](/blog/2016/05/21/convert-python-objects-to-json/), the keys are printed out of order since they are unordered in the internal dictionary `__dict__`.
In theory, it does not matter when converting to/from JSON.
However, it sometimes makes sense for the keys to be printed in order, especially when we need to look for two keys in JSON next to each other or one key before another.
For example, in the `Config` object in the last post, it is better to see `source` and `target` configurations side by side and, then, get to know what kind of tests from `testName` key before reading details of tests in `queries` key.
Setting `sort_keys` option in `json.dump` is not applicable here since the keys will be sorted by their names, not their order of appearance like we do in the Java example. 

To have the keys appear in order as defined when converting to JSON, we have two options:

### Option 1: use OrderedDict as your base class

This option is just a quick and dirty workaround: our `Config` class should extend `collections.OrderedDict` class and, in the code, we refer to `object["att"]` instead of `object.att`.

``` python Example of using OrderedDict as your Config class
class OrderedConfig(collections.OrderedDict):
    pass

def ordered_config_file(filename, query_generator):

    hive_source = OrderedConfig()
    hive_source["type"] = "hive"
    hive_source["url"] = "jdbc:hive2://192.168.5.184:10000/DWH"
    vertica_target = OrderedConfig()
    vertica_target["type"] = "vertica"
    vertica_target["url"] = "jdbc:vertica://192.168.5.174:5433/VMart"

    config = OrderedConfig()
    config["source"] = hive_source
    config["target"] = vertica_target
    config["testName"] = "count"
    config["queries"] = query_generator

    with open(filename, 'w') as config_file:
        json.dump(config, config_file, indent=4)
```

We have some extra typing, but in general, it is good enough for some configuration objects.
Note that you can now dump your configuration object directly into file because it now behaves like a dictionary.

``` json Pretty print
{
    "source": {
        "type": "hive", 
        "url": "jdbc:hive2://192.168.5.184:10000/DWH"
    }, 
    "target": {
        "type": "vertica", 
        "url": "jdbc:vertica://192.168.5.174:5433/VMart"
    }, 
    "testName": "count", 
    "queries": "..."
}
```

### Option 2: use OrderedDict as your attribute dictionary.

In order to refer to attributes directly as `object.att` and still get JSON ordered like in the Java example, it will need some works.
Note that the obvious solution `__dict__ = OrderedDict()` will NOT work due to a Python bug. 

``` python Failed attempt due to a Python bug
class Config(object):
   def __init__(self):
       self.__dict__ = collections.OrderedDict()
       

  with open(filename, 'w') as config_file:
      json.dump(config, config_file, default=vars, indent=4)
```

I got an empty object as my JSON output.
It can be pretty confusing since we can still refer to attributes using standard notation `object.att` and correctly retrieve values.
After searching the web, I finally figured out that it is a known bug, as documented [here](https://mail.python.org/pipermail/python-bugs-list/2006-April/033155.html).
It says that if `__dict__` is not an actual `dict()`, then it is ignored, and attribute lookup fails if using that dictionary directly.

To work around that problem, we have to use `OrderedDict` as an attribute in `__dict__` and modify `__getattr__` and `__setattr__` methods to use this `OrderedDict` instead.
The modified `Config` class and modified `default=` parameter is shown below.

``` python Modified Config class
class Config(object):

    ODICT = "odict"

    def __init__(self):
        self.__dict__[self.ODICT] = collections.OrderedDict()

    def __getattr__(self, item):
        return self.__dict__[self.ODICT][item]

    def __setattr__(self, key, value):
        self.__dict__[self.ODICT][key] = value
```

``` python Modified JSON dump
    with open(filename, 'w') as config_file:
        json.dump(config, config_file, default=lambda o: vars(o)[Config.ODICT], indent=4)
```

The JSON output now has the keys appear in the order as they are defined, similar to Jackson example above:

``` json Pretty print with ordering
{
    "source": {
        "type": "hive", 
        "host": "192.168.5.184", 
        "user": "cloudera", 
        "password": "password", 
        "url": "jdbc:hive2://192.168.5.184:10000/DWH"
    }, 
    "target": {
        "type": "vertica", 
        "host": "192.168.5.174", 
        "user": "dbadmin", 
        "password": "password", 
        "url": "jdbc:vertica://192.168.5.174:5433/VMart"
    }, 
    "testName": "count", 
    "queries": "..."
}
```

With that, for configuration editing purposes, using the Python object to JSON conversion is more convenient than Java (POJO) to JSON conversion. 
We can add new custom attributes if needed without having to define a new class.
The `Config` class is all you need for all configuration writing.
The full working code for converting Python object to JSON is shown below.

``` python Full code
import collections
import json

class Config(object):

    ODICT = "odict"

    def __init__(self):
        self.__dict__[self.ODICT] = collections.OrderedDict()

    def __getattr__(self, item):
        return self.__dict__[self.ODICT][item]

    def __setattr__(self, key, value):
        self.__dict__[self.ODICT][key] = value

    pass

def get_hive_config():
    """ Get pre-defined Hive configuration.

    :return: Config object for Hive.
    """

    conn = Config()
    conn.type = "hive"
    conn.host = "192.168.5.184"
    conn.user = "cloudera"
    conn.password = "password"
    conn.url = "jdbc:hive2://192.168.5.184:10000/DWH"

    return conn

def get_vertica_config():
    """ Get pre-defined Vertica configuration.

    :return: Config object for Vertica.
    """

    conn = Config()
    conn.type = "vertica"
    conn.host = "192.168.5.174"
    conn.user = "dbadmin"
    conn.password = "password"
    conn.url = "jdbc:vertica://192.168.5.174:5433/VMart"

    return conn

def create_config_file(filename, query_generator):

    hive_source = get_hive_config()
    vertica_target = get_vertica_config()

    config = Config()
    config.source = hive_source
    config.target = vertica_target
    config.testName = "count"
    config.queries = query_generator

    with open(filename, 'w') as config_file:
        json.dump(config, config_file, default=lambda o: vars(o)[Config.ODICT], indent=4)

def main():

    FILE_NAME = "hive_vertica_count.json"
    query_generator = generate_count_queries()
    create_config_file(FILE_NAME, query_generator)

if __name__ == "__main__":
    main()
```

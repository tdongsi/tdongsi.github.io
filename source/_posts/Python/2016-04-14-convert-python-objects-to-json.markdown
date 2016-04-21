---
layout: post
title: "Convert Python objects to JSON"
date: 2016-04-25 22:09:50 -0700
comments: true
categories: 
- Python
- Java
---

### JSON serialization in Java

In Java, it is pretty straight forward to convert Java objects (POJO) to JSON using [Jackson library](https://github.com/FasterXML/jackson).
The following code will convert an example POJO to JSON:

``` java Example POJO
public class Config {
	
	public String type;
	public String host;
	public String user;
	public String password;
	public String url;
	
}
```

``` java Jackson examples
ObjectMapper mapper = new ObjectMapper();
Config conn = new Config();
conn.type = "hive";
conn.host = "192.168.5.184";
conn.user = "cloudera";
conn.password = "password";
conn.url = "jdbc:hive2://192.168.5.184:10000/DWH";

// POJO to JSON in file
mapper.writeValue(new File("config.json"), obj);
// POJO to JSON in String
String jsonInString = mapper.writerWithDefaultPrettyPrinter()
		.writeValueAsString(conn);
```

The JSON output is shown below. 
Note that the keys (e.g., "type", "host") appear in the same order as defined in the `Config` class.
This will become important later when we try to convert Python objects to JSON.

``` json JSON representation of Config object
{
  "type" : "hive",
  "host" : "192.168.5.184",
  "user" : "cloudera",
  "password" : "password",
  "url" : "jdbc:hive2://192.168.5.184:10000/DWH"
}
```

### JSON serialization in Python

In Python, we have `json` module to convert a *serializable* object to JSON format.
The first attempt at JSON serlaization in Python may look something like this, with a slightly complex Python object is used as an example:

``` python First attempt at JSON serialization
class Config(object):
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
        json.dump(config, config_file)


def main():

    FILE_NAME = "hive_vertica_count.json"
    query_generator = generate_count_queries()
    create_config_file(FILE_NAME, query_generator)
```

This first attempt with `json.dump(config, config_file)` will fail with the following error:

``` python JSON serialization error
TypeError: <__main__.Config object at 0x10ab824d0> is not JSON serializable
```

As the message indicates, `Config` object is not JSON serializable. 
`json.dump` expects a serializable object such as one of Python standard object types (see Python to JSON mapping table below) or their subclasses.

| Python | JSON |
| --- | --- |
| dict | object |
| list, tuple | array |
| str, unicode | string |
| int, long, float | number |
| True | true |
| False | false |
| None | null |

<br>

The solution is to specify the `default` parameter with a function that returns object's `__dict__` attribute.
`__dict__` is the internal attribute dictionary that contains all attributes associated with an object.
Object attribute references are translated to lookups in this dictionary, e.g., `C.x` is translated to `C.__dict__["x"]`.

``` python Correct options
    with open(filename, 'w') as config_file:
        json.dump(config, config_file, default=lambda o: o.__dict__, indent=4)
```

``` python Pretty print without ordering
{
    "source": {
        "url": "jdbc:hive2://192.168.5.184:10000/DWH", 
        "host": "192.168.5.184", 
        "password": "password", 
        "type": "hive", 
        "user": "cloudera"
    }, 
    "queries": "...", 
    "target": {
        "url": "jdbc:vertica://192.168.5.174:5433/VMart", 
        "host": "192.168.5.174", 
        "password": "password", 
        "type": "vertica", 
        "user": "dbadmin"
    }, 
    "testName": "count"
}
```

Note that simply using `json.dump(config.__dict__, config_file)` will NOT work either if any attribute of the object is another complex object (e.g., `source` and `target` attributes in this example).
Note that for more complex objects such as those include `set`s, we may have to define our own Encoder that extends `json.JSONEncoder` and provide it to `dump` function.

### Unordered keys in JSON output

In the JSON output shown in the last section, the keys are out of order.
In theory, it does not matter when converting to/from JSON.
However, it sometimes makes sense to look for two keys in JSON next to each other or one key before another, i.e., keys are ordered.
For example, in the `Config` object above, it is better to see `source` and `target` keys side by side, or get to know what kind of tests from `testName` key before reading details of tests in `queries` key.
`sort_keys` option in `json.dump` is not applicable since the keys will be then sorted by their names, not their order of appearance like we do in Java. 

To have the key name appears in order as defined when converting to JSON, we have two options:

#### Option 1: use OrderedDict as your base class

The first option is just a quick and dirty workaround: our `Config` class should extend `collections.OrderedDict` class and, in the code, we refer to `object["att"]` instead of `object.att`.

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
Note that you can now dump your configuration object directly into file since it now behaves like a dictionary.

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

#### Option 2: use OrderedDict as your attribute dictionary.

TODO

 `__dict__ = OrderedDict()` will not work. On the opposite, it is a catastrophic failure since now you cannot add attributes now. TODO: cite link.

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
        json.dump(config, config_file, default=lambda o: o.__dict__[Config.ODICT], indent=4)
```

The output

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

Now it is superior to Java. You can add new custom attributes if needed without having to define a new class.

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
        json.dump(config, config_file, default=lambda o: o.__dict__[Config.ODICT], indent=4)

def main():

    FILE_NAME = "hive_vertica_count.json"
    query_generator = generate_count_queries()
    create_config_file(FILE_NAME, query_generator)

if __name__ == "__main__":
    main()
```
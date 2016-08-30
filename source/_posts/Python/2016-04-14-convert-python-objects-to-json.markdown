---
layout: post
title: "Convert Python objects to JSON"
date: 2016-05-21 22:09:50 -0700
comments: true
categories: 
- Python
- Java
---

### JSON serialization in Java

In Java, it is pretty straight-forward to convert Java objects (POJO) to JSON using [Jackson library](https://github.com/FasterXML/jackson).
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
The first attempt at JSON serialization in Python may look like this, with a slightly complex Python object is intentionally used as an example:

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
`json.dump` function expects a serializable object such as one of Python standard object types (see Python to JSON mapping table below) or their subclasses.

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

The solution for that problem is to specify the `default` parameter with a function that returns object's `__dict__` attribute.
`__dict__` is the internal attribute dictionary that contains all attributes associated with an object.
Object attribute references are translated to lookups in this dictionary, e.g., `o.x` is translated to `o.__dict__["x"]`.

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

Note that simply using `json.dump(config.__dict__, config_file)` will NOT work if any attribute of the object is another complex object (e.g., `source` and `target` attributes in this example).
For more complex objects such as those include `set`s, we may have to define our own Encoder that extends `json.JSONEncoder` and provide it to `json.dump` function.
The next [post](/blog/2016/05/25/convert-python-objects-to-json-ordered-keys/) will discuss how to print keys in order of which they are defined, like in the Java example.
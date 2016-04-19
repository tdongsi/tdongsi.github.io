---
layout: post
title: "Convert Python objects to JSON"
date: 2016-04-25 22:09:50 -0700
comments: true
categories: 
- Python
- Java
---

In Java, it is pretty straight forward to convert Java objects (POJO) to JSON using [Jackson library](https://github.com/FasterXML/jackson).

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

The output is shown below. 
Note that the keys (e.g., "type", "host") appear in the same order as defined in the `Config` class.

``` json JSON representation of Config object
{
  "type" : "hive",
  "host" : "192.168.5.184",
  "user" : "cloudera",
  "password" : "password",
  "url" : "jdbc:hive2://192.168.5.184:10000/DWH"
}
```

In Python, we have `json` module. TODO: add more

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

Note that `json.dump(config, config_file)` does not work.

``` python JSON serialization error
TypeError: <__main__.Config object at 0x10ab824d0> is not JSON serializable
```

`json.dump(config.__dict__, config_file)` will not work either if any attribute of the `config` object is a complex object (e.g., `source` and `target` attributes in this example).

The solution is to define TODO

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
    "queries": "TODO", 
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
---
layout: post
title: "Convert Python objects to JSON"
date: 2016-04-21 22:09:50 -0700
comments: true
categories: 
- Python
- Java
---

In Java, it is pretty straight forward to convert Java objects (POJO) to JSON using [Jackson library](https://github.com/FasterXML/jackson).

``` java Jackson examples
ObjectMapper mapper = new ObjectMapper();
Config obj = new Config();

// POJO to JSON in file
mapper.writeValue(new File("config.json"), obj);
// POJO to JSON in String
String jsonInString = mapper.writeValueAsString(obj);
```

In Python, `json` module.

``` python Pretty print
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

Ordering

``` python Pretty print with ordering
```
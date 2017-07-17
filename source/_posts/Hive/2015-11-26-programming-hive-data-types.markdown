---
layout: post
title: "Learning Hive (Pt. 4): Data Types"
date: 2015-11-26 18:01:37 -0800
comments: true
published: true
categories: 
- Book
- Hive
- Hadoop
- SQL
---

This post covers different data types and file formats supported by Hive.

<!--more-->

### Data Types

The following primitive data types are supported:

- TINYINT: 1 byte signed integer
- SMALLINT: 2 bytes
- INT: 4 bytes
- BIGINT: 8 bytes
- BOOLEAN
- FLOAT
- DOUBLE
- STRING: Single or double quotes can be used for literals.
- TIMESTAMP: Integer, float, or string.
    - Integer: For seconds from Unix epoch.
    - Float: Seconds from Unix epoch and nanoseconds.
    - String: JDBC-compliant java.sql.Timestamp format convention, i.e. YYYY-MM-DD hh:mm:ss.fffffffff
- BINARY: array of bytes. Used to include arbitrary bytes and prevent Hive from attempting to parse them.

As you can see, Hive supports most basic primitive data types conventionally found in relational databases. Moreover, it helps to remember that these data types are implemented in Java, so their behaviors will be similar to their Java counterparts.

NOTE: Not mentioned in the **Programming Hive** book, but the types `DECIMAL` and `DATE` are introduced since Hive 0.13.0. 
In addition, the book claimed "Hive does not support character arrays with maximum-allowed lengths, as is common in other SQL dialects" but `VARCHAR` type, introduced in Hive 0.12.0, does exactly that.

Besides primitive data types, Hive supports the following collection data types:

- STRUCT: Analogous to a C `struct` or POJO (Plain Old Java Object). The elements can be accessed using the DOT (.) notation.
    - Example: Declaration -> `struct<name:string,id:int>`. Literal -> `struct('John',1)`.
- MAP: A collection of key-value tuples. The elements can be accessed using array notation, e.g. persons['John'].
    - Example: Declaration -> `map<string,int>`. Literal -> `map('John',1)`.
- ARRAY: Ordered sequences of the same type. The elements can be accessed using array notation, e.g. person[2].
    - Example: Declaration -> `array<string>`. Literal -> `array('John','Peter')`.

Relational databases don't usually support such collection types because they tend to break **normal form**. 
In Hive/Hadoop, sacrificing normal form is pretty common as it can give benefit of higher processing throughput, especially with large amount of data (tens of terabytes).

### Text File Formats

Hive can use comma-separated values (CSV) or tab-separated values (TSV) text file format. A Hive table declaration with all row format specified (with default values, however) looks like this:

``` sql
CREATE TABLE employees (
  name         STRING,
  salary       FLOAT,
  subordinates ARRAY<STRING>,
  deductions   MAP<STRING, FLOAT>,
  address      STRUCT<street:STRING, city:STRING, state:STRING, zip:INT>
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY '\001'
COLLECTION ITEMS TERMINATED BY '\002'
MAP KEYS TERMINATED BY '\003'
LINES TERMINATED BY '\n'
STORED AS TEXTFILE;
```

### Schema on Read

Different from databases, Hive has no control over the underlying storage: for example, you can modify files on HDFS that Hive will query. Hive tries its best to read the data and match the schema. If the file content does not match the schema such as non-numeric strings found when numbers expected, you may get null values.

### Additional References

As of November 2015, the **Programming Hive (2nd edition)** book uses slightly a outdated Hive version 0.9.0 (Chapter 2, Installing Hive). Information in the following links are used when writing this post:

1. https://cwiki.apache.org/confluence/display/Hive/LanguageManual+Types
2. https://cwiki.apache.org/confluence/display/Hive/Tutorial
3. https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DDL

---
layout: post
title: "Programming Hive: Data Types"
date: 2015-11-24 18:01:37 -0800
comments: true
published: false
categories: 
- Book
- Hive
- Hadoop
- JDBC
- SQL
---

“Hive supports many of the primitive data types you find in relational databases, as well as three collection data types”
“A unique feature of Hive, compared to most databases, is that it provides great flexibility in how data is encoded in files. Most databases take total control of the data, both how it is persisted to disk and its life cycle”

Primitive data types:

- TINYINT: 1 byte
- SMALLINT: 2 bytes
- INT: 4 bytes
- BIGINT: 8 bytes
- BOOLEAN
- FLOAT
- DOUBLE
- STRING
- TIMESTAMP: Integer, float, or string.
    - Integer: For seconds from Unix epoch
    - Float: + nanoseconds
    - String: JDBC-compliant java.sql.Timestamp format convention, YYYY-MM-DD hh:mm:ss.fffffffff
- BINARY: array of bytes

Notes:
“Hive does not support “character arrays” (strings) with maximum-allowed lengths, as is common in other SQL dialects. Relational databases offer this feature as a performance optimization; fixed-length records are easier to index, scan. “Hadoop and Hive emphasize optimizing disk reading and writing performance, where fixing the lengths of column values is relatively unimportant.”
“TIMESTAMPS are interpreted as UTC times. Built-in functions for conversion to and from timezones are provided by Hive, to_utc_timestamp and from_utc_timestamp, respectively”
“The BINARY type is similar to the VARBINARY type. “BINARY can be used as a way of including arbitrary bytes in a record and preventing Hive from attempting to parse them as numbers, strings, etc.”

Collection data types:
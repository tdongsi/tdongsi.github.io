---
layout: post
title: "Learning Hive (Pt. 7): Partitioned tables"
date: 2015-12-06 21:09:51 -0800
comments: true
published: true
categories:
- Book
- Hive
- Hadoop
- SQL
---

<!--
Chapter 4
-->

Continued from the [previous](/blog/2015/12/02/programming-hive-hiveql-ddl/) [posts](/blog/2015/12/05/programming-hive-ddl-table/), this post will look into more details of **partitioned tables**. 
Note that Hive does not support row-level inserts, updates, and deletes. 
However, Hive adds extensions such as table partitioning for better performance in the context of Hadoop.

<!--more-->

### Partitioned Managed Tables

In general, partitioning data means distributing data load horizontally, moving data physically closer to its most frequent users. In Hive, partitioning tables changes how Hive structures its data storage for some performance gain.

In "Programming Hive", the authors present a hypothetical problem where one will regularly query some `employees` table by country and state, e.g., all employees in California, US or Alberta, Canada. Therefore, partitioning this table by country and state is a logical thing to do.

``` sql
CREATE TABLE employees (
  name         STRING,
  salary       FLOAT,
  subordinates ARRAY<STRING>,
  deductions   MAP<STRING, FLOAT>,
  address      STRUCT<street:STRING, city:STRING, state:STRING, zip:INT>
)
PARTITIONED BY (country STRING, state STRING);
```

Without `PARTITIONED BY` clause, Hive will store data for these tables in a subdirectory `employees` under the directory defined by `hive.metastore.warehouse.dir` (see [Managed tables](/blog/2015/12/05/programming-hive-ddl-table/)). However, Hive will now create subdirectories inside `employees` directory for the above partitioning structure:

``` bash
...
.../employees/country=CA/state=AB
.../employees/country=CA/state=BC
...
.../employees/country=US/state=AL
.../employees/country=US/state=AK
...
```

The actual directory names depends on values of *partition keys* (e.g., country and state). For very large data sets, partitioning can improve query performance, but only if the partitioning scheme reflects common range filtering (e.g., by countries or states). When we add predicates to WHERE clauses that filter on partition values, these predicates are called *partition filters* (e.g., `WHERE state = 'CA'`).

You can view the partitions in a table with `SHOW PARTITIONS`, as shown in examples below:

``` sql
SHOW PARTITIONS college;

/* DESCRIBE EXTENDED also shows partition keys */
SHOW PARTITIONS employees PARTITION( country=‘US’);
```

#### Strict mode

Given a partitioned table, a query across all partitions can result in a enormous MapReduce job, especially for a huge data set. It is probably desirable to put in place a safety measure which prohibits queries without any filter on partitions. Hive has a "strict" mode for that.

``` bash
hive> set hive.mapred.mode;
hive.mapred.mode=nonstrict

hive> set hive.mapred.mode = strict;
hive> SELECT e.name FROM employees e; /* does not work */
```

### Partitioned External Tables

You can use partitioning with external tables. The combination gives you a way to “share” data with other tools, while still optimizing query performance. While LOCATION clause is required for non-partitioned external table to specify data location, it is not required for external partitioned tables. Instead, `ALTER TABLE` statement is used to add data in each partition separately.

``` sql
CREATE EXTERNAL TABLE IF NOT EXISTS log_messages (
  hms             INT,
  severity        STRING,
  server          STRING,
  process_id      INT,
  message         STRING)
PARTITIONED BY (year INT, month INT, day INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

ALTER TABLE log_messages ADD PARTITION(year = 2012, month = 1, day = 2)
LOCATION 'hdfs://master_server/data/log_messages/2012/01/02';

DESCRIBE EXTENDED log_messages PARTITION (year=2012);
```

Note that `ALTER TABLE … ADD PARTITION` is not limited to external tables. You can use it with managed tables, too. However, it is not recommended since you have to manually keep track of this partition and remember to delete data in case you want to completely drop the managed table.

#### Example use case of partitioned external tables
 
For example, each day we might use the following procedure to move data older than a month to S3:

1) Copy the data for the partition being moved to S3. For example, you can use the hadoop distcp command:
``` bash
     hadoop distcp /data/log_messages/2011/12/02 s3n://ourbucket/logs/2011/12/02
```
2) Alter the table to point the partition to the S3 location:
``` sql
     ALTER TABLE log_messages PARTITION(year = 2011, month = 12, day = 2)
     SET LOCATION 's3n://ourbucket/logs/2011/01/02';
```
3) Remove the HDFS copy of the partition using the hadoop fs -rmr command:
``` bash
     hadoop fs -rmr /data/log_messages/2011/01/02
```

### Altering Partitioned Tables

Some basic `ALTER TABLE` statements for manipulating table partitions are shown in the following examples:

``` sql
/* Add partition */
ALTER TABLE log_messages ADD IF NOT EXISTS
PARTITION (year = 2011, month = 1)
LOCATION ‘/logs/2011/01';

/* Change partition location */
ALTER TABLE log_messages PARTITION (year = 2011, month = 1)
SET LOCATION ‘/bucket/logs/2011/01’;

/* Drop partition */
ALTER TABLE log_messages DROP IF EXISTS PARTITION (year = 2011, month = 1);

/* Alter storage properties of partition */
ALTER TABLE log_messages
PARTITION(year = 2012, month = 1, day = 1)
SET FILEFORMAT SEQUENCEFILE;

/* Archive partition */
ALTER TABLE log_messages ARCHIVE
PARTITION(year = 2012, month = 1, day = 1);
```

The `ALTER TABLE ... ARCHIVE PARTITION` statement captures the partition files into a Hadoop archive (HAR) file. This only reduces the number of files in the filesystem, reducing the load on the NameNode, but doesn’t provide any space savings. To reverse the operation, substitute UNARCHIVE for ARCHIVE. This feature is only available for individual partitions of partitioned tables.
---
layout: post
title: "Programming Hive: Partitioned tables"
date: 2015-12-05 21:09:51 -0800
comments: true
published: false
categories:
- Book
- Hive
- Hadoop
- SQL
---

### Partitioned, Managed Tables
Partitioning data is distributing load horizontally, moving data physically closer to its most frequent users.
Partitioning tables changes how Hive structures the data storage.

“Hive will now create subdirectories reflecting the partitioning structure. For example with partition keys ‘country’ and ’state':
...
.../employees/country=CA/state=AB
.../employees/country=CA/state=BC
...
.../employees/country=US/state=AL
.../employees/country=US/state=AK
...”

“Once created, the partition keys (country and state, in this case) behave like regular columns. In fact, users of the table don’t need to care if these “columns” are partitions or not, except when they want to optimize query performance.”
“For very large data sets, partitioning can dramatically improve query performance, but only if the partitioning scheme reflects common range filtering (e.g., by locations, timestamp ranges). When we add predicates to WHERE clauses that filter on partition values, these predicates are called partition filters.”

“A highly suggested safety measure is putting Hive into “strict” mode, which prohibits queries of partitioned tables without a WHERE clause that filters on partitions.”

```
> set hive.mapred.mode = strict;
> SELECT e.name FROM employees e; — does not work
> set hive.mapred.mode = nonstrict;

— Create partitioned table
> CREATE TABLE college (
)
PARTITIONED BY (country STRING, state STRING);

> SHOW PARTITIONS college;
> SHOW PARTITIONS employees PARTITION( country=‘US’);
— DESCRIBE EXTENDED also shows partition keys

“LOAD DATA LOCAL INPATH '${env:HOME}/california-employees'
INTO TABLE employees
PARTITION (country = 'US', state = 'CA');
```

The directory for this partition, …/employees/country=US/state=CA, will be created by Hive and all data files in $HOME/california-employees will be copied into it”

External Partitioned Tables

“You can use partitioning with external tables. In fact, you may find that this is your most common scenario for managing large production data sets. The combination gives you a way to “share” data with other tools, while still optimizing query performance.”

While LOCATION clause is required for non-partitioned external table, it is not required for external partitioned tables. Instead, use ALTER TABLE statement is used to add each partition separately.

> CREATE EXTERNAL TABLE IF NOT EXISTS log_messages (
  hms             INT,
  severity        STRING,
  server          STRING,
  process_id      INT,
  message         STRING)
PARTITIONED BY (year INT, month INT, day INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t';

> ALTER TABLE log_messages ADD PARTITION(year = 2012, month = 1, day = 2)
LOCATION 'hdfs://master_server/data/log_messages/2012/01/02';

> DESCRIBE EXTENDED log_messages PARTITION (year=2012);

Example use case:

For example, each day we might use the following procedure to move data older than a month to S3:
1) Copy the data for the partition being moved to S3. For example, you can use the hadoop distcp command:
     hadoop distcp /data/log_messages/2011/12/02 s3n://ourbucket/logs/2011/12/02
2) Alter the table to point the partition to the S3 location:
     ALTER TABLE log_messages PARTITION(year = 2011, month = 12, day = 2)
     SET LOCATION 's3n://ourbucket/logs/2011/01/02';
3) Remove the HDFS copy of the partition using the hadoop fs -rmr command:
     hadoop fs -rmr /data/log_messages/2011/01/02”

“Hive doesn’t care if a partition directory doesn’t exist for a partition or if it has no files. In both cases, you’ll just get no results for a query that filters for the partition.”

Note: “ALTER TABLE … ADD PARTITION is not limited to external tables. You can use it with managed tables, too. You’ll need to remember that not all of the table’s data will be under the usual Hive “warehouse” directory, and this data won’t be deleted when you drop the managed table! Hence, from a “sanity” perspective, it’s questionable whether you should dare to use this feature with managed tables.”

### Altering partition

```
— Add partition
> ALTER TABLE log_messages ADD IF NOT EXISTS
PARTITION (year = 2011, month = 1)
LOCATION ‘/logs/2011/01';

— Change partition location
> ALTER TABLE log_messages PARTITION (year = 2011, month = 1)
SET LOCATION ‘/bucket/logs/2011/01’;

— Drop partition
> ALTER TABLE log_messages DROP IF EXISTS PARTITION (year = 2011, month = 1);
```

Others:

Alter storage properties:
“ALTER TABLE log_messages
PARTITION(year = 2012, month = 1, day = 1)
SET FILEFORMAT SEQUENCEFILE;”

“The ALTER TABLE … ARCHIVE PARTITION statement captures the partition files into a Hadoop archive (HAR) file. This only reduces the number of files in the filesystem, reducing the load on the NameNode, but doesn’t provide any space savings (e.g., through compression):
ALTER TABLE log_messages ARCHIVE
PARTITION(year = 2012, month = 1, day = 1);
To reverse the operation, substitute UNARCHIVE for ARCHIVE. This feature is only available for individual partitions of partitioned tables.”
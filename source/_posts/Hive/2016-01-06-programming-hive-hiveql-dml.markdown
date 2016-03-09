---
layout: post
title: "Hive Tutorial (Pt. 8): Data Manipulation in HiveQL"
date: 2015-12-12 23:34:38 -0800
comments: true
published: true
categories: 
- Hive
- SQL
- Book
- Hadoop
---

<!--
{% img center /images/hive/cat.gif Cover %}

Chapter 5 of the book
-->

This post is about HiveQL's parts used to put data into tables and extract data from tables to the filesystem.


### LOAD

Since Hive has no row-level insert, update, and delete operations, the only way to put data into an table is to use one of the “bulk” load operations.

``` sql Hive LOAD
> LOAD DATA LOCAL INPATH '/home/ca-employees'
OVERWRITE INTO TABLE employees
PARTITION ( country = 'US', state = 'CA' ); -- remove this if the target is not partitioned
```

This `LOAD` command will first create the directory for the partition, if it doesn’t already exist, then copy the data to it.
It is conventional practice to specify a path that is a directory, rather than an individual file. 
Hive will copy all the files in the directory, which give you the flexibility of organizing the data into multiple files and changing the file naming convention, without requiring a change to your Hive scripts.

If the LOCAL keyword is used, the path is assumed to be in the local filesystem. The data is copied into the final location. 
If LOCAL is omitted, the path is assumed to be in the distributed filesystem. In this case, the data is moved from the path to the final location.
You can’t use `LOAD DATA` to load (move) data from one HDFS cluster to another since files are moved, Hive requires the source and target files in the same filesystem.
Relative paths can be used.

If you specify the `OVERWRITE` keyword, any data already present in the target directory will be deleted first. 
Without the keyword, the new files are simply added to the target directory. 
However, if files already exist in the target directory that match filenames being loaded, the old files are overwritten.

### INSERT

The `INSERT` statement lets you load data into a table from a query.

``` sql Hive INSERT
> INSERT OVERWRITE TABLE employees
PARTITION ( country = 'US', state = 'OR' )
SELECT * FROM staged_employees se
WHERE se.cnty = 'US' AND se.st = 'OR';
```

If you drop the keyword `OVERWRITE` or replace it with `INTO`, Hive appends the data rather than replaces it.
Hive also offers an alternative `INSERT` syntax that allows you to scan the input data once and split it multiple ways.

``` sql
> FROM staged_employees se
INSERT OVERWRITE TABLE employees
  PARTITION (country = 'US', state = 'OR')
SELECT * WHERE se.cnty = 'US' AND se.st = 'OR'
INSERT OVERWRITE TABLE employees
  PARTITION (country = 'US', state = 'CA')
  SELECT * WHERE se.cnty = 'US' AND se.st = 'CA'
INSERT OVERWRITE TABLE employees
  PARTITION (country = 'US', state = 'IL')
  SELECT * WHERE se.cnty = 'US' AND se.st = 'IL';
```

You can also create a table and insert query results into it in one statement:

``` sql
> CREATE TABLE ca_employees
AS SELECT name, salary, address
FROM employees
WHERE se.state = 'CA';
```

### Dynamic partition

```
> INSERT OVERWRITE TABLE employees
PARTITION (country, state)
SELECT ..., se.cnty, se.st
FROM staged_employees se;
```

You can also mix dynamic and static partitions. This variation of the previous query specifies a static value for the country (US) and a dynamic value for the state:

```
> INSERT OVERWRITE TABLE employees
PARTITION (country = 'US', state)
SELECT ..., se.cnty, se.st
FROM staged_employees se
WHERE se.cnty = 'US';
```

Dynamic partitioning is not enabled by default. When it is enabled, it works in “strict” mode by default.

``` plain Hive settings
> set hive.exec.dynamic.partition=true;
> set hive.exec.dynamic.partition.mode=nonstrict;
```

### Exporting data

If the data files are already formatted the way you want, then it’s simple enough to copy the directories or files:

``` bash
hadoop fs -cp source_path target_path
```

Otherwise, you can use `INSERT ... DIRECTORY ...` statement, as in this example:

``` sql Export from Hive
> INSERT OVERWRITE LOCAL DIRECTORY '/tmp/ca_employees'
SELECT name, salary, address
FROM employees
WHERE se.state = 'CA';
```

---
layout: post
title: "Learning Hive (Pt. 8): Data Manipulation in HiveQL"
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

<!--more-->

### LOAD

Hive has no row-level insert, update, and delete operations. Instead, we use one of its many "bulk" load operations to put data into a table.

``` sql Hive LOAD
> LOAD DATA LOCAL INPATH '/home/ca-employees'
OVERWRITE INTO TABLE employees
PARTITION ( country = 'US', state = 'CA' ); -- remove this if the target is not partitioned
```

This `LOAD` command will first create the directory for the partition, if necessary, then copy the data to it.
If the `LOCAL` keyword is specified, the path is assumed in the local filesystem. 
If you use the `OVERWRITE` keyword, any data present in the target directory will be removed. 
Without the keyword, the new files are added to the target directory.
More details can be found [here](https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DML).

### INSERT

The `INSERT` statement will load data into a table, as shown below:

``` sql Hive INSERT
> INSERT OVERWRITE TABLE employees
PARTITION ( country = 'US', state = 'OR' )
SELECT * FROM staged_employees se
WHERE se.cnty = 'US' AND se.st = 'OR';
```

If the keyword `OVERWRITE` is replaced with `INTO`, Hive appends the data instead of replaces it.

<!--
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
-->
Similar to other SQL dialects, you can also `CREATE TABLE` and insert `SELECT` query results into the new table in a single statement:

``` sql
> CREATE TABLE ca_employees
AS SELECT name, salary, address
FROM employees
WHERE se.state = 'CA';
```

<!--
### Dynamic partition

```
> INSERT OVERWRITE TABLE employees
PARTITION (country, state)
SELECT ..., se.cnty, se.st
FROM staged_employees se;
```

You can also mix dynamic and static partitions. The following query specifies a static value for the country (US) and a dynamic value for the state:

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
-->

### Exporting data

If you want the data files as is, then exporting data can be as simple as copying the directories or files:

``` bash
hadoop fs -cp source_path target_path
```

Otherwise, you can use `INSERT ... DIRECTORY ...` statement with associated `SELECT` statement to specify the data you want, as in this example:

``` sql Export from Hive
> INSERT OVERWRITE LOCAL DIRECTORY '/tmp/ca_employees'
SELECT name, salary, address
FROM employees
WHERE se.state = 'CA';
```

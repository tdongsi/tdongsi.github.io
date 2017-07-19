---
layout: post
title: "Learning Hive (Pt. 5): HiveQL Data Definition"
date: 2015-12-02 18:32:21 -0800
comments: true
published: true
categories:
- Book
- Hive
- Hadoop
- SQL
---

This post covers data definition parts of HiveQL language, for creating, altering, and dropping **databases**.

<!--more-->

### Databases

In Hive, the concept of a database is basically just a namespace of tables. The keyword SCHEMA can be used instead of DATABASE in all the database-related commands. If you don’t specify a database, the `default` database is used.


Some basic HiveQL's database commands is shown in the following examples:

``` sql
CREATE DATABASE college;
CREATE DATABASE IF NOT EXISTS college;

SHOW DATABASES;
SHOW DATABASES LIKE 'h.*';

CREATE DATABASE college
LOCATION '/my/preferred/directory';

/* add comments to table */
CREATE DATABASE college COMMENT 'A college admission database';
/* show comments */
DESCRIBE DATABASE college;

/* add properties */
CREATE DATABASE college WITH DBPROPERTIES ( 'creator' = 'CD', 'date' = 'today' );
/* show properties */
DESCRIBE DATABASE EXTENDED college;

/* set working database */
USE college;
/* this will show tables in this database */
SHOW TABLES;

DROP DATABASE IF EXISTS college;
/* Drop tables if there is any table in the database */
DROP DATABASE IF EXISTS college CASCADE;

/* You can set additional key-value pairs in properties.
 * No other metadata about the database can be changed. No way to delete a DB PROPERTY.
 */
ALTER DATABASE college SET DBPROPERTIES ('editor' = 'DC');
```

Note that Hive will create separate directory for each database. The exception is the `default` database, which doesn't have its own directory. Tables in each database will be stored in subdirectories of the database directory. The location of the database directory is specified by the property `hive.metastore.warehouse.dir`. To help us understand better, these are illustrated by the Hive CLI commands as follows:

``` bash
[cloudera@quickstart temp]$ hive

Logging initialized using configuration in file:/etc/hive/conf.dist/hive-log4j.properties
hive> describe database default;
OK
default	Default Hive database	hdfs://quickstart.cloudera:8020/user/hive/warehouse	public	ROLE	
Time taken: 0.01 seconds, Fetched: 1 row(s)
hive> describe database college;
OK
college		hdfs://quickstart.cloudera:8020/user/hive/warehouse/college.db	cloudera	USER	
Time taken: 0.011 seconds, Fetched: 1 row(s)

hive> SET hive.metastore.warehouse.dir;
hive.metastore.warehouse.dir=/user/hive/warehouse

hive> dfs -ls hdfs://quickstart.cloudera:8020/user/hive/warehouse/college.db;
Found 3 items
drwxrwxrwx   - hive hive          0 2015-01-21 11:29 hdfs://quickstart.cloudera:8020/user/hive/warehouse/college.db/apply
drwxrwxrwx   - hive hive          0 2015-01-20 15:22 hdfs://quickstart.cloudera:8020/user/hive/warehouse/college.db/college
drwxrwxrwx   - hive hive          0 2015-01-28 15:26 hdfs://quickstart.cloudera:8020/user/hive/warehouse/college.db/student
hive> dfs -ls hdfs://quickstart.cloudera:8020/user/hive/warehouse/college.db/student;
Found 1 items
-rwxrwxrwx   1 cloudera hive        213 2015-01-20 15:22 hdfs://quickstart.cloudera:8020/user/hive/warehouse/college.db/student/student.data
hive> dfs -ls hdfs://quickstart.cloudera:8020/user/hive/warehouse/college.db/college;
Found 1 items
-rwxrwxrwx   1 cloudera hive         66 2015-01-20 15:22 hdfs://quickstart.cloudera:8020/user/hive/warehouse/college.db/college/college.data
```

In the output of the `DESCRIBE DATABASE` commands above, the directory location of the database is shown, with `hdfs` as URI scheme. Note that `hdfs://quickstart.cloudera:8020/user/hive/warehouse/college.db` is equivalent to `hdfs://user/hive/warehouse/college.db`, where `quickstart.cloudera:8020` is simply the master node’s DNS name and port on Cloudera Quickstart VM. The name of the database directory is always `database_name.db`, with `.db` suffix added to database name. The three tables `college`, `student`, and `apply` in the `college` database are created as sub-directories in that `college.db` directory, as shown above. When a database is dropped, its directory is also deleted. By default, Hive will not allow you to drop a database that contains tables. The second `DROP DATABASE` command with `CASCADE` will force Hive to drop the database by dropping the tables in the database first.

There is no command to show the current working database. When in doubt, it is safe to use the command `USE database_name;` repeatedly since there is no nesting of databases in Hive. Otherwise, you can set a property to show the current working database in Hive CLI prompt as follows:

```
hive> set hive.cli.print.current.db=true;
hive (default)> USE college;
OK
Time taken: 0.278 seconds
hive (college)> 
```

---
layout: post
title: "Programming Hive (Pt. 5): HiveQL Data Definition"
date: 2015-11-30 18:32:21 -0800
comments: true
published: true
categories:
- Book
- Hive
- Hadoop
- SQL
---

{% img center /images/hive/cat.gif Cover %}

Chapter 4 of the book covers data definition parts of HiveQL language, mostly for creating, altering, and dropping databases and tables. It defers discussion of views hapter 7, indexes until Chapter 8, and functions until Chapter 13.

### Databases

In Hive, the concept of a database is basically just a namespace of tables. The keyword SCHEMA can be used instead of DATABASE in all the database-related commands. If you don’t specify a database, the default database is used.


Some basic HiveQL's database commands:

``` sql
> CREATE DATABASE college;
> CREATE DATABASE IF NOT EXISTS college;

> SHOW DATABASES;
> SHOW DATABASES LIKE ‘h.*’;

> CREATE DATABASE college
> LOCATION ‘/my/preferred/directory’;

—- add comments
> CREATE DATABASE college
> COMMENT ‘A college admission database’;
—- show comments
> DESCRIBE DATABASE college;

—- add properties
> CREATE DATABASE college
> WITH DBPROPERTIES ( ‘creator’ = ‘CD’, ‘date’ = ‘today’ );
— show properties
> DESCRIBE DATABASE EXTENDED college;

—- set working database
> USE college;
— this will show tables in this database
> SHOW TABLES;

> DROP DATABASE IF EXISTS college;
—- Drop tables if there is any table in the database
> DROP DATABASE IF EXISTS college CASCADE;

—- You can set additional key-value pairs in properties.
—- No other metadata about the database can be changed. No way to delete a DB PROPERTY.
> ALTER DATABASE college SET DBPROPERTIES (‘editor’ = ‘DC’);
```

NOTES:

“Hive will create a directory for each database. Tables in that database will be stored in subdirectories of the database directory. The exception is tables in the default database, which doesn’t have its own directory.”
“The database directory is created under a top-level directory specified by the property hive.metastore.warehouse.dir, with the default value is /user/hive/warehouse, when the financials database is created, Hive will create the directory /user/hive/warehouse/financials.db. Note the .db extension.”

“In the output of DESCRIBE DATABASE, we’re showing master-server to indicate the URI authority, in this case a DNS name and optional port number (i.e., server:port) for the “master node” of the filesystem (i.e., where the NameNode service is running for HDFS). If you are running in pseudo-distributed mode, then the master server will be localhost. For local mode, the path will be a local path, file:///user/hive/warehouse/financials.db.”
“To be clear, hdfs:///user/hive/warehouse/financials.db is equivalent to hdfs://master-server/user/hive/warehouse/financials.db, where master-server is your master node’s DNS name and optional port.
For completeness, when you specify a relative path (e.g., some/relative/path), Hive will put this under your home directory in the distributed filesystem (e.g., hdfs:///user/<user-name>) for HDFS.”

> USE college;
“there is no command to show you which database is your current working database! Fortunately, it’s always safe to repeat the USE … command; there is no concept in Hive of nesting of databases.”
OR
“hive> set hive.cli.print.current.db=true;

hive (financials)> USE default;”

DROP DATABASE
“By default, Hive won’t permit you to drop a database if it contains tables. You can either drop the tables first or append the CASCADE keyword to the command, which will cause the Hive to drop the tables in the database first”
“Using the RESTRICT keyword instead of CASCADE is equivalent to the default behavior, where existing tables must be dropped before dropping the database. When a database is dropped, its directory is also deleted.”

=== Tables ===

> CREATE TABLE IF NOT EXISTS mydb.employees (
  name STRING COMMENT ‘Employee name’,
  salary FLOAT COMMENT ‘Employee salary’,
)
COMMENT ‘Description of the table'
TBLPROPERTIES ( ‘creator’ = ‘me’ )
LOCATION ‘/user/hive/warehouse/mydb.db/employees’; — the location is the default location

> SHOW TBLPROPERTIES mydb.employees;
> SHOW TABLES;
> SHOW TABLES IN mydb;
> USE mydb;
> SHOW TABLES ‘empl.*’; — use regex to search tables in current database

— copy the schema of an existing table
— you can specify LOCATION but no other can be defined
> CREATE TABLE IF NOT EXISTS mydb.clone LIKE mydb.employees;

> DESCRIBE EXTENDED mydb.employees;
> DESCRIBE FORMATTED mydb.employees; — more readable and verbose
> DESCRIBE mydb.employees.name; — see schema for a column

— Create external table
— Read all data files with comma-delimited format
— from /data/stocks
— LOCATION is required for external table
> CREATE EXTERNAL TABLE IF NOT EXISTS stocks (
  exchange        STRING,
  symbol          STRING,
  volume          INT,
  price_adj_close FLOAT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/data/stocks';

— Copy external table
> CREATE EXTERNAL TABLE IF NOT EXISTS ext_clone
LIKE stocks
LOCATION ‘/path/to/data’;

— Drop table
— For managed tables, the table metadata and data are deleted.
— For external tables, the metadata is deleted but the data is not.
DROP TABLE IF EXISTS college;

Warning: “f you use IF NOT EXISTS and the existing table has a different schema than the schema in the CREATE TABLE statement, Hive will ignore the discrepancy.”
“Hive automatically adds two table properties: last_modified_by holds the username of the last user to modify the table, and last_modified_time holds the epoch time in seconds of that modification.”
“Using the IN database_name clause and a regular expression for the table names together is not supported.”

Managed tables vs External tables:
“The tables we have created so far are called managed tables or sometimes called internal tables, because Hive controls the lifecycle of their data”
When we drop a managed table, Hives deletes the data in the table.
“Suppose we have data that is created and used primarily by Pig or other tools, but we want to run some queries against it, but not give Hive ownership of the data. We can define an external table that points to that data, but doesn’t take ownership of it.”

Dropping external table does not delete the data, although the metadata will be deleted.
“The differences between managed and external tables are smaller than they appear at first. Even for managed tables, you know where they are located.”
External table is based on a general principle of good software design, that is to express intent. If the data is shared, creating an external table makes this ownership explicit.

Copying schema for external table: CREATE [EXTERNAL] TABLE … LIKE ...
“If you omit the EXTERNAL keyword and the original table is external, the new table will also be external. If you omit EXTERNAL and the original table is managed, the new table will also be managed. However, if you include the EXTERNAL keyword and the original table is managed, the new table will be external. Even in this scenario, the LOCATION clause will still be optional.”

Partitioned, Managed Tables
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

=== Altering tables ===

> ALTER TABLE college RENAME TO university;

— Add partition
> ALTER TABLE log_messages ADD IF NOT EXISTS
PARTITION (year = 2011, month = 1)
LOCATION ‘/logs/2011/01'
…;

— Change partition location
> ALTER TABLE log_messages PARTITION (year = 2011, month = 1)
SET LOCATION ‘/bucket/logs/2011/01’;

— Drop partition
> ALTER TABLE log_messages DROP IF EXISTS PARTITION (year = 2011, month = 1);

— Change columns: rename, change its position, type, or comment
— The keyword COLUMN is optional, as well as COMMENT clause
— This command changes metadata only. The data has to be moved to match the new columns if needed.
> ALTER TABLE log_messages
CHANGE COLUMN hms hours_minutes_seconds INT
COMMENT ‘New comment'
AFTER severity; — use FIRST if the column is moved to first

— Add columns, to the end of existing columns
— Use CHANGE COLUMN to rearrange if needed
> ALTER TABLE log_messages
ADD COLUMNS (
app_name STRING COMMENT ‘New column 1’,
session_id INT COMMENT ‘New column 2'
);

— Remove all the existing columns and replaces with new specified columns
> ALTER TABLE log_messages
REPLACE COLUMNS (
app_name STRING COMMENT ‘New column 1’,
session_id INT COMMENT ‘New column 2'
);

— You can add table properties or set current properties, but not remove them
> ALTER TABLE log_messages
SET TBLPROPERTIES (
‘some_key’ = ‘some_value'
);

Others:

Alter storage properties:
“ALTER TABLE log_messages
PARTITION(year = 2012, month = 1, day = 1)
SET FILEFORMAT SEQUENCEFILE;”

“The ALTER TABLE … ARCHIVE PARTITION statement captures the partition files into a Hadoop archive (HAR) file. This only reduces the number of files in the filesystem, reducing the load on the NameNode, but doesn’t provide any space savings (e.g., through compression):
ALTER TABLE log_messages ARCHIVE
PARTITION(year = 2012, month = 1, day = 1);
To reverse the operation, substitute UNARCHIVE for ARCHIVE. This feature is only available for individual partitions of partitioned tables.”
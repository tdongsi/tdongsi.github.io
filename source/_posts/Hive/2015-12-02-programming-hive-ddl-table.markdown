---
layout: post
title: "Learning Hive (Pt. 6): HiveQL Data Definition"
date: 2015-12-05 20:15:56 -0800
comments: true
published: true
categories:
- Book
- Hive
- Hadoop
- SQL
---

Continued from the previous [post](/blog/2015/12/02/programming-hive-hiveql-ddl/), this post covers data definition parts of HiveQL language, for creating, altering, and dropping **tables**.

<!--more-->

### Creating Tables

Some basic HiveQL's table DDL commands are shown in the following examples:

``` sql
/* NOTE: the LOCATION clause uses the default location */
CREATE TABLE IF NOT EXISTS college.student (
  name STRING COMMENT 'Student name',
  sid INT COMMENT 'Student ID',
)
COMMENT 'Description of the table' TBLPROPERTIES ( 'creator' = 'me' )
LOCATION '/user/hive/warehouse/college.db/student';

/* 
 * copy the schema of an existing table
 * you can specify optional LOCATION but no other can be defined
 */
CREATE TABLE IF NOT EXISTS mydb.clone LIKE mydb.employees;

/*
* Create external table
* Read all data files with comma-delimited format
* from /data/stocks
* LOCATION is required for external table
*/
CREATE EXTERNAL TABLE IF NOT EXISTS stocks (
  exchange        STRING,
  symbol          STRING,
  volume          INT,
  price_adj_close FLOAT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/data/stocks';

/*
* Copy external table schema.
*/
CREATE EXTERNAL TABLE IF NOT EXISTS ext_clone
LIKE stocks
LOCATION '/path/to/data';

/*
* Drop table
* For managed tables, the table metadata and data are deleted.
* For external tables, the metadata is deleted but the data is not.
*/
DROP TABLE IF EXISTS college;
```

Note that in the first `CREATE TABLE` command, you can prefix a database name, e.g. `mydb`, even when it is not your current working database. As usual, the optional `IF NOT EXISTS` clause will ignore the statement if the table already exists, even when the schema does not match (no warning from Hive). The second `CREATE TABLE` command is useful to copy the schema of an existing table. The corresponding commands for **external** table are also shown above (note `EXTERNAL TABLE`). The concept of external table in Hive will be discussed shortly.

The `SHOW TABLES` command lists the tables. You use different variants of that command to find tables of interest as shown below:

``` bash
hive> use college;
OK
Time taken: 0.048 seconds


/* Show list of tables in current database */
hive> show tables;
OK
apply
college
student
Time taken: 0.031 seconds, Fetched: 3 row(s)

/* Show list of tables in the specified database */
hive> show tables in college;
OK
apply
college
student
Time taken: 0.034 seconds, Fetched: 3 row(s)

/* use regex to search tables in current database */
hive> show tables '.*e.*';
OK
college
student
Time taken: 0.025 seconds, Fetched: 2 row(s)


/* Show table properties */
hive> show tblproperties student;        
OK
COLUMN_STATS_ACCURATE	true
comment	List of students
numFiles	1
numRows	0
rawDataSize	0
totalSize	213
transient_lastDdlTime	1421796179
Time taken: 0.28 seconds, Fetched: 7 row(s)
```

You can use `DESCRIBE` command to display table information as shown below:
```
hive> describe extended student;        
OK
sid                 	int                 	Student ID          
sname               	string              	Student name        
gpa                 	float               	Student GPA         
sizehs              	int                 	Size of student highschool
	 	 
Detailed Table Information	Table(tableName:student, dbName:college, owner:cloudera, createTime:1421796178, lastAccessTime:0, retention:0,
sd:StorageDescriptor(cols:[FieldSchema(name:sid, type:int, comment:Student ID), FieldSchema(name:sname, type:string, comment:Student name), ...
Time taken: 0.119 seconds, Fetched: 6 row(s)


/* more readable and verbose */
hive> describe formatted student;
OK
# col_name            	data_type           	comment             
	 	 
sid                 	int                 	Student ID          
sname               	string              	Student name        
gpa                 	float               	Student GPA         
sizehs              	int                 	Size of student highschool
	 	 
# Detailed Table Information	 	 
Database:           	college             	 
Owner:              	cloudera            	 
CreateTime:         	Tue Jan 20 15:22:58 PST 2015	 
LastAccessTime:     	UNKNOWN             	 
Protect Mode:       	None                	 
Retention:          	0                   	 
Location:           	hdfs://quickstart.cloudera:8020/user/hive/warehouse/college.db/student	 
Table Type:         	MANAGED_TABLE       	 
Table Parameters:	 	 
	COLUMN_STATS_ACCURATE	true                
	comment             	List of students    
	numFiles            	1                   
	numRows             	0                   
	rawDataSize         	0                   
	totalSize           	213                 
	transient_lastDdlTime	1421796179          
	 	 
# Storage Information	 	 
SerDe Library:      	org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe	 
InputFormat:        	org.apache.hadoop.mapred.TextInputFormat	 
OutputFormat:       	org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat	 
Compressed:         	No                  	 
Num Buckets:        	-1                  	 
Bucket Columns:     	[]                  	 
Sort Columns:       	[]                  	 
Storage Desc Params:	 	 
	field.delim         	;                   
	serialization.format	;                   
Time taken: 0.108 seconds, Fetched: 36 row(s)

/* see schema for a column */
hive> describe student.sid;
OK
sid                 	int                 	from deserializer   
Time taken: 0.315 seconds, Fetched: 1 row(s)
```

### Managed tables vs. External tables

`CREATE TABLE` commands (without `EXTERNAL`) create *managed tables* or *internal tables*. 
It is internal/managed because the life cycle of their data is managed by Hive. 
By default, Hive stores data for these tables in a subdirectory under the directory defined by `hive.metastore.warehouse.dir`, as illustrated below (see [Hive CLI](/blog/2015/11/23/programming-hive-hive-cli/) for `SET` and `dfs` commands). 
When we drop a managed table with `DROP TABLE` command, the data in the table will be deleted.

```
hive> SET hive.metastore.warehouse.dir;
hive.metastore.warehouse.dir=/user/hive/warehouse
hive> dfs -ls /user/hive/warehouse/college.db;
Found 3 items
drwxrwxrwx   - hive hive          0 2015-01-21 11:29 /user/hive/warehouse/college.db/apply
drwxrwxrwx   - hive hive          0 2015-12-03 15:16 /user/hive/warehouse/college.db/college
drwxrwxrwx   - hive hive          0 2015-01-28 15:26 /user/hive/warehouse/college.db/student
```

As mentioned in [Schema on Read](/blog/2015/11/26/programming-hive-data-types/), Hive does not have control over the underlying storage, even for *managed table*: for example, you can totally use another `dfs` command in the last example to modify files on HDFS.

Managed tables are not convenient for sharing data with other tools. 
Instead, *external tables* can be defined to point to that data, but don't take ownership of data. 
In the `CREATE EXTERNAL TABLE` command example at the beginning of this post, the data files are in HDFS at `/data/stocks` and the external table will be created and populated by reading all comma-delimited data files in that location. 
The `LOCATION` clause is required for external table, to tell Hive where it is located. 
Dropping an external table does not delete the data since Hive does not *own* the data. 
However, the *metadata* for that table will be deleted.

To tell whether if a table is managed or external, use the command `DESCRIBE FORMATTED`. In the example in the last section, we see that the table `college.student` is a managed table because of its output:

```
Location:           	hdfs://quickstart.cloudera:8020/user/hive/warehouse/college.db/student	 
Table Type:         	MANAGED_TABLE 
```

For external tables, the output will be like `Table Type: EXTERNAL_TABLE`.

### Altering Tables

The `ALTER TABLE` statements *only* change *metadata* of the table, but not the data in the table. It's up to us to ensure that any schema modifications are consistent with the actual data.

Some basic `ALTER TABLE` statements for renaming table and changing table columns are shown in the following examples: 

``` sql
/* Renaming table */
ALTER TABLE college RENAME TO university;

/*
 * Change columns: rename, change its position, type, or comment.
 * The keyword COLUMN is optional, as well as COMMENT clause.
 * This command changes metadata only. 
 * The data has to be moved to match the new columns if needed.
 * Use FIRST, instead of AFTER, if the column is moved to first.
 */
ALTER TABLE log_messages
CHANGE COLUMN hms hours_minutes_seconds INT
COMMENT 'New comment'
AFTER severity;

/*
 * Add columns, to the end of existing columns.
 * Use CHANGE COLUMN to rearrange if needed.
 */
ALTER TABLE log_messages
ADD COLUMNS (
app_name STRING COMMENT 'New column 1',
session_id INT COMMENT 'New column 2');

/*
 * Remove all the existing columns and replaces with new 
 * specified columns.
 */
ALTER TABLE log_messages
REPLACE COLUMNS (
app_name STRING COMMENT 'New column 1',
session_id INT COMMENT 'New column 2');

/* 
 * You can add table properties or set current properties,
 * but not remove them 
 */
ALTER TABLE log_messages
SET TBLPROPERTIES (
'some_key' = 'some_value'
);
```


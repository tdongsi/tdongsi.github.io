---
layout: post
title: "Vertica Tip: Find empty tables"
date: 2015-12-18 21:39:56 -0800
comments: true
categories: 
- Vertica
- SQL
- Database
---

This post is a reminder of using Vertica's system tables for administrating and monitoring our own tables. One common house-cleaning operation when developing/testing in Vertica is to find and drop tables that are empty (truncated) and never used again. 

You might ask why the tables are not dropped directly when I truncated the table in the first place. The answer is that all those tables have some specific designs on projection segmentation and partition, and those information will be lost if I drop the tables. These tables are frequently populated with data and cleared for testing purposes, and truncating and inserting with `direct` [hint](https://my.vertica.com/docs/7.1.x/HTML/Content/Authoring/SQLReferenceManual/Statements/INSERT.htm) will give a significant performance boost (see [Best practices](/blog/2015/12/16/vertica-tip-best-practices/)).

<!--more-->

### v\_monitor schema and COLUMN_STORAGE system table

The [COLUMN_STORAGE system table](https://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/SQLReferenceManual/SystemTables/MONITOR/COLUMN_STORAGE.htm) in `v_monitor` schema returns the "amount of disk storage used by each column of each projection on each node". Therefore, to get the size of each table, you only need to aggregate the `used_byte` data, grouped by schema name and table name.

``` sql Query to list tables' sizes in a schema
select anchor_table_schema, anchor_table_name, sum(used_bytes)
FROM v_monitor.column_storage
where anchor_table_schema = 'some_schema'
group by anchor_table_schema, anchor_table_name
```

According to [here](http://vertica.tips/2014/01/25/table-size/), the number from the above query is the *compressed* size of the Vertica tables. To get the *raw* size of the tables, which probably only matters for license limit, perform a *license audit*, and query the system table `license_audits` in `v_catalog` schema. However, the most important takeaway is that empty tables will not appear in this `COLUMN_STORAGE` system table.

### v\_catalog schema and TABLES system table

The [TABLES system table](https://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/SQLReferenceManual/SystemTables/CATALOG/TABLES.htm) is probably more well-known. It contains all the information about all the tables in all the schemas. For example, to list all the tables in some schema:

``` sql Query to list all tables in a schema
select table_schema, table_name from tables
where table_schema = 'some_schema'
```

Another useful system table in `v_catalog` schema is `USER_FUNCTIONS` which lists all user-defined functions and their function signatures in the database. 

### Find all the empty (truncated) tables

Having all the tables in `v_catalog.tables` table and only non-empty tables in `v_monitor.column_storage` table, finding empty tables is pretty straight-forward in SQL:

``` sql Query to find empty tables in a schema
select table_name
from v_catalog.tables
where table_schema = 'some_schema'
EXCEPT
select anchor_table_name
from v_monitor.column_storage
where anchor_table_schema = 'some_schema' 
``` 

### External Links

1. [Finding table's compressed size](http://vertica.tips/2014/01/25/table-size/)
1. [Vertica License audit](http://vertica.tips/2014/01/24/license-audit-utilization-raw-size/)
1. [COLUMN_STORAGE system table](https://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/SQLReferenceManual/SystemTables/MONITOR/COLUMN_STORAGE.htm)
1. [TABLES system table](https://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/SQLReferenceManual/SystemTables/CATALOG/TABLES.htm)
1. [USER_FUNCTIONS system table](https://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/SQLReferenceManual/SystemTables/CATALOG/USER_FUNCTIONS.htm)
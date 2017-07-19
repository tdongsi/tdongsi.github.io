---
layout: post
title: "NZSQL tips for new Netezza users"
date: 2015-12-07 11:11:06 -0800
comments: true
categories: 
- Database
- SQL
---

Just like any SQL dialect, NZSQL has some quirks and odd conventions which could be really confusing to new Netezza users.
This post has some tips for those new users.

<!--more-->

* By default, identifiers are treated as UPPERCASE, even if you type them as LOWERCASE. So, for example, these create statements:

``` sql
create table my_table (name varchar(80), address varchar(80));
create table my_table (NaMe varchar(80), adDresS varchar(80));
```
  are equivalent to:
  
``` sql
create table my_table (NAME varchar(80), ADDRESS varchar(80));
```
  The same is true for `SELECT` statements. These two SQL statements:
  
``` sql
select name from my_table;
select NaMe from my_table;
```
  are equivalent to:
  
``` sql
select NAME from my_table;
```

* The best practice is that you should never care or override the above default behavior: your identifiers should be case-insensitive. Unfortunately, if you have to override the above default behavior, then you must surround the identifier with double-quotes whenever you reference it. For example, if you create a table using this statement:

``` sql
create table my_table ("Name" varchar(80), "Address" varchar(80));
```  
then you must reference the identifiers by surrounding them with double-quotes. For example:
  
``` sql
select "Name" from my_table;
```

* The most perplexing feature for new Netezza users when reading a NZSQL script is probably the "dot dot" notation of database object names, i.e., the two dots in `my_dwh..companies`. It is simply the short-hand notation for database object names, `database-name..object-name`. The fully qualified form of object names in Netezza has **three-level** as `database-name.schema.object-name`. One example of using such notation is shown below:

``` sql
select count(*) from (select company_name from my_dwh..companies where company_name like '%e%') as x;
```
  
#### External Links

1. [Database Object Naming](https://www-304.ibm.com/support/knowledgecenter/SSULQD_7.2.0/com.ibm.nz.dbu.doc/c_dbuser_database_object_naming.html)
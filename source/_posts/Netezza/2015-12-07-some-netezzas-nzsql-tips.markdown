---
layout: post
title: "Some Netezza's NZSQL tips"
date: 2015-12-07 11:11:06 -0800
comments: true
categories: 
- SQL
- Netezza
---

1. By default, identifiers are treated as UPPERCASE, even if you type them as LOWERCASE. So, for example, these create statements:

    ```
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
  
    ```
    select NAME from my_table;
    ```
2. If you really want to override the above default behavior, then you must surround the identifier with double-quotes whenever you reference it. For example, if you create a table using this statement:

    ``` sql
    create table my_table ("Name" varchar(80), “Address" varchar(80));
    ```  
  then you must reference the identifiers by surrounding them with double-quotes. For example:  
  
    ``` sql
    select "Name" from my_table;
    ```
3. Before you begin to query a database table, you should count the records in the table, so you get a sense as to the size of your results set.

  ``` sql
  select count(*) from (select company_name from my_dwh..companies where company_name like '%e%') as x;
  ```
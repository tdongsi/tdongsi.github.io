---
layout: post
title: "Vertica: Performance Optimization Notes"
date: 2016-02-13 23:52:44 -0800
comments: true
published: true
categories: 
- Vertica
- Performance
- SQL
---

In this post, most of optimization notes for Vertica performance are from our team's interaction with [Nexius](http://www.nexius.com/software-and-business-intelligence/) consultants. 
Also see [Vertica Best Practices](/blog/2015/12/16/vertica-tip-best-practices/).

<!--more-->

### `NOT IN` better than `NOT EXISTS`

When we want to insert a row into a dimension table AND check for duplicates at the same time, we usually do this in DML scripts:

``` sql BAD
SELECT 'United States', 'English' 
WHERE NOT EXISTS (SELECT 'x' FROM dim_country WHERE country_name = 'United States')
```

However, for all such inserts, we were recently informed that it is better **in Vertica** to do `NOT IN` instead of `NOT EXISTS`.
So, for example above:

``` sql GOOD
SELECT 'United States', 'English' 
WHERE 'United States' NOT IN (select country_name from dim_country)
```

### Avoid using `LEFT JOIN` to check existence

Let's say we have an ETL that regularly inserts new data into an existing dimension table.  

``` sql BAD
INSERT INTO dim_country                    
(
    country_id,
    country_name,
    country_language,
) 
SELECT ssp.country_id,
    ssp.country_name,
    ssp.country_language,
FROM staging_table ssp
LEFT JOIN dim_country dc on dc.country_id=ssp.country_id
WHERE dc.country_id is NULL;
```

We are sometimes doing `LEFT JOIN` like this only to determine whether or not an entry already exists in the table. 
It would be faster to use a `WHERE` clause instead to perform that existence check. 
Although it might sound counter-intuitive, but reducing `JOIN` operations like this has been regularly recommended.

``` sql GOOD
INSERT INTO dim_country                    
(
    country_id,
    country_name,
    country_language,
) 
SELECT ssp.country_id,
    ssp.country_name,
    ssp.country_language,
FROM staging_table ssp
WHERE ssp.country_id NOT IN (SELECT country_id FROM dim_country);
```

### Avoid function calls in `WHERE` and `JOIN` clauses

For this performance tip, we make a slight change to the example ETL in the last section above where `country_id` column is removed. In this case, we can use a normalized `country_name` as the ID to check for existing entries in the table:

``` sql BAD
INSERT INTO dim_country                    
(
    country_name,
    country_language,
) SELECT ssp.country_name,
    ssp.country_language,
FROM staging_table ssp
LEFT JOIN dim_country dc on lower(dc.country_name)=lower(ssp.country_name)
WHERE dc.country_name is NULL;
```

In this example, we normalize `country_name` to lower case. Note that `WHERE` clause should be used instead of `LEFT JOIN` as discussed above. 

``` sql BETTER, but still BAD
INSERT INTO dim_country                    
(
    country_name,
    country_language,
) SELECT ssp.country_name,
    ssp.country_language,
FROM staging_table ssp
WHERE lower(ssp.country_name) NOT IN (SELECT lower(country_name) FROM dim_country);;
```
 
However, such change still has bad performance because, in general, function calls in `WHERE` and `JOIN` clauses should be avoided in Vertica. 
In both examples above, calling functions like `LOWER` in `WHERE` and `JOIN` clauses will affect the performance of the ETLs.

The solution for this scenario is that, since we control what goes into dimension tables, we can ensure that columns like `country_name` are always stored in lower-case. 
Then, we can do the same when creating the temporary table such as `staging_table` that we are comparing to for checking existence.

### Use  [ANALYZE_STATISTICS](https://my.vertica.com/docs/7.1.x/HTML/Content/Authoring/SQLReferenceManual/Functions/VerticaFunctions/ANALYZE_STATISTICS.htm)

Make sure to run `ANALYZE_STATISTICS` after all data loads.
Using this function, tables are analyzed for best performance in subsequent queries ran against it.
Without information from `ANALYZE_STATISTICS`, the query optimizer assumes uniform distribution of data values and equal storage usage for all projections.

Note that `ANALYZE_STATISTICS` is only supported on *local* temporary tables, but not on *global* temporary tables.
In addition, when we add `ANALYZE_STATISTICS` function calls into our ETL scripts, errors might be thrown when a second `ANALYZE_STATISTICS` call is made while the first is still running. 
Those errors can be ignored but they must be caught accordingly to separate with other Vertica error messages.

### Avoid creating temporary tables using `SELECT`

Instead of creating temporary tables using `SELECT`, it is recommended to:

1. Create the temporary table first without a projection.
1. Create a super [projection](/blog/2016/02/07/vertica-post-7/) with the correct column encodings and `ORDER BY` clause
1. Populate it using `INSERT /*+ direct */ INTO`. Note the `/*+ direct */` hint to write data directly to disk, bypassing memory.
1. Run `ANALYZE_STATISTICS`. See the last section.

For example, in a Vertica ETL script that runs daily, we usually create a temporary table to retrieve the latest records from a source table like this:

``` sql BAD
CREATE TEMPORARY TABLE customer_last_temp 
ON COMMIT PRESERVE ROWS
AS(
  select * from (
    select *,
    row_number() OVER (PARTITION BY customer_id ORDER BY last_modify_date DESC) AS rank 
    from  stg_customer rpt 
  ) t1 where t1.rank =1
);
```

In this example, `last_modify_date` is the [CDC](https://en.wikipedia.org/wiki/Change_data_capture) column and `customer_id` is the primary key column. 
Although this SQL statement is simple and easy to understand, it is really slow for a large and growing `stg_customer` table that contains updates to all customers on multiple dates, with millions of *new* customer entries each day. 
Instead, the recommended coding pattern is to create a temporary table first without a projection:

``` sql Create a temporary table without projection
CREATE LOCAL TEMPORARY TABLE customer_last_temp  ( 
        customer_id                   	int,
        subscribe_date               	timestamp,
        cancel_date                  	timestamp,
        last_modify_date             	timestamp,
)
ON COMMIT PRESERVE ROWS NO PROJECTION;
```

It is also recommended that the column names are explicitly specified, so that only required columns are created in the temporary table. 
A `LOCAL` temporary table is created, instead of `GLOBAL`, so that we can use `ANALYZE_STATISTICS` functions as discussed above. 
Next, create a super projection with the correct column encodings and `ORDER BY` clause:

``` sql Create a super projection
CREATE PROJECTION customer_last_temp_super (
      customer_id ENCODING DELTARANGE_COMP 
    , subscribe_date ENCODING GCDDELTA
    , cancel_date ENCODING BLOCKDICT_COMP     
    , last_modify_date ENCODING BLOCKDICT_COMP 
)
AS 
SELECT customer_id 
     , subscribe_date
     , cancel_date
     , last_modify_date
  FROM customer_last_temp 
 ORDER BY customer_id
SEGMENTED BY HASH (customer_id) ALL NODES;
```

Finally, insert "directly" into the temporary table:

``` sql Populate the table
INSERT /*+ direct */ INTO customer_last_temp (
      customer_id 
    , subscribe_date 
    , cancel_date 
    , last_modify_date 
)
WITH t1 AS (
    SELECT company_id 
         , subscribe_date 
         , cancel_date 
         , last_modify_date 
         , ROW_NUMBER() OVER (PARTITION BY customer_id 
                                  ORDER BY last_modify_date DESC) AS rank 
      FROM stg_customer AS rpt 
)
SELECT company_id 
     , subscribe_date 
     , cancel_date 
     , last_modify_date 
FROM t1
WHERE t1.rank = 1;  
```

The `WITH` clause is just a more readable way to write the sub-query in the original SQL statement (see [WITH clause](/blog/2016/02/03/vertica-post-8/)). 
In addition, the wildcard `*` in the original SQL query is also avoided, in case the table `stg_customer` is a very wide table.





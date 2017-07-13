---
layout: post
title: "Vertica tip: Best practices"
date: 2015-12-16 23:12:06 -0800
comments: true
categories: 
- Database
- Vertica
- SQL
- Performance
---

This post lists some tips and tricks that I learnt when working with Vertica database.

<!--more-->

### General Tips and Tricks

#### CREATE (INSERT)

* If you want to write data directly to disk and bypass memory, then you should include `/*+ direct */` as a "hint" in your `INSERT` statement. This is especially helpful when you are loading data from big files into Vertica. If you don't use `/*+ direct */`, then `INSERT` statement first uses memory, which may be more useful when you want to optimally do inserts and run queries.

* ALWAYS include `COMMIT` in your SQL statements when you are creating or updating Vertica schemas, because there is NO auto commit in Vertica.

* If you are copying a table, **DO NOT** use `CREATE TABLE copy AS SELECT * FROM source`. This will give you a copy table with default projections and storage policy. Instead, you should use `CREATE TABLE` statement with the [`LIKE existing_table` clause](https://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/AdministratorsGuide/Tables/CreatingATableLikeAnother.htm) and use `INSERT /*+ direct */` statement. Creating a table with `LIKE` option replicates the table definition and storage policy associated with the source table, which can make a significant difference in data loading performance. Note that the `LIKE` clause does not work if the existing source table is a temporary table.

``` sql DO NOT do this
create table to_schema.to_table_name
as select * from from_schema.from_table_name;
```

``` sql DO this
CREATE TABLE to_schema.to_table_name LIKE from_schema.from_table_name INCLUDING PROJECTIONS;
INSERT /*+ direct */ INTO to_schema.to_table_name SELECT * from from_schema.from_table_name;
```

* Before making a copy of a table, be sure to consider alternatives in order to execute optimal queries: create views, rewrite queries, use sub-queries, limit queries to only a subset of data for analysis.

#### READ

* Avoid joining large tables (e.g., > 50M records). Run a `count(*)` on tables before joining and use `MERGE JOIN` to optimally join tables. When you use smaller subsets of data, the Vertica Optimizer will pick the `MERGE JOIN` algorithm instead of the `HASH JOIN` one, which is less optimal.

* When an approximate value will be enough, Vertica offers an alternative to `COUNT(DISTINCT)`: `APPROXIMATE_COUNT_DISTINCT`. This function is recommended when you have a large data set and you do not require an exact count of distinct values: e.g., sanity checks that verify the tables are populated. According to [this documentation](http://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/AnalyzingData/Optimizations/OptimizingCOUNTDISTINCTByCalculatingApproximateCounts.htm), you can get much better performance than `COUNT(DISTINCT)`. [Here](http://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/SQLReferenceManual/Functions/Aggregate/APPROXIMATE_COUNT_DISTINCT.htm) is an example of the `APPROXIMATE_COUNT_DISTINCT` syntax that you should use.

#### UPDATE & DELETE

* Deletes and updates take exclusive locks on the table. Hence, only one `DELETE` or `UPDATE` transaction on that table can be in progress at a time and only when no `INSERTs` are in progress. Deletes and updates on different tables can be run concurrently.

* Try to avoid `DELETE` or `UPDATE` as much as you can, especially on shared Vertica databases. Instead, it may work better to move the data you want to update to a new temporary table, work on that copy, drop the original table, and rename the temporary table with the original table name. For example:

``` sql
CREATE temp_table LIKE src_table INCLUDING PROJECTIONS;
INSERT INTO temp_table (SELECT statement based on the updated data or the needed rows);
DROP TABLE src_table;
ALTER TABLE temp_table RENAME TO src_table;
```

* Delete from tables marks rows with delete vectors and stores them so data can be rolled back to a previous epoch. The data must be eventually purged before the database can reclaim disk space.

### Query plan

A query plan is a sequence of step-like paths that the HP Vertica cost-based query optimizer selects to access or alter information in your HP Vertica database. You can get information about [query plans](https://my.vertica.com/docs/7.0.x/HTML/Content/Authoring/AdministratorsGuide/EXPLAIN/HowToGetQueryPlanInformation.htm) by prefixing the SQL query with the `EXPLAIN` command.

``` sql EXPLAIN statement
EXPLAIN SELECT customer_name, customer_state FROM customer_dimension
WHERE customer_state in ('MA','NH') AND customer_gender = 'Male'     
ORDER BY customer_name LIMIT 10;
```  

The output from a query plan is presented in a tree-like structure, where each step path represents a single operation in the database that the optimizer uses for its execution strategy. The following example output is based on the previous query:
 
``` bash Query Plan description
EXPLAIN SELECT
customer_name,
customer_state
FROM customer_dimension
WHERE customer_state in ('MA','NH')
AND customer_gender = 'Male'
ORDER BY customer_name
LIMIT 10;
Access Path:
+-SELECT  LIMIT 10 [Cost: 370, Rows: 10] (PATH ID: 0)
|  Output Only: 10 tuples
|  Execute on: Query Initiator
| +---> SORT [Cost: 370, Rows: 544] (PATH ID: 1)
| |      Order: customer_dimension.customer_name ASC
| |      Output Only: 10 tuples
| |      Execute on: Query Initiator
| | +---> STORAGE ACCESS for customer_dimension [Cost: 331, Rows: 544] (PATH ID: 2) 
| | |      Projection: public.customer_dimension_DBD_1_rep_vmartdb_design_vmartdb_design_node0001
| | |      Materialize: customer_dimension.customer_state, customer_dimension.customer_name
| | |      Filter: (customer_dimension.customer_gender = 'Male')
| | |      Filter: (customer_dimension.customer_state = ANY (ARRAY['MA', 'NH']))
| | |      Execute on: Query Initiator
```

If you want to understand the details of the query plan, observe the real-time flow of data through the plan to identify possible query bottlenecks, you can:

1. query the [V_MONITOR.QUERY_PLAN_PROFILES](https://my.vertica.com/docs/7.1.x/HTML/Content/Authoring/SQLReferenceManual/SystemTables/MONITOR/QUERY_PLAN_PROFILES.htm) system table.
1. review [Profiling Query Plans](https://my.vertica.com/docs/7.1.x/HTML/Content/Authoring/AdministratorsGuide/Profiling/ProfilingQueryPlanProfiles.htm).
1. use [PROFILE](https://my.vertica.com/docs/7.1.x/HTML/Content/Authoring/SQLReferenceManual/Statements/PROFILE.htm) statement to view further detailed analysis of your query.

### External Links

1. [Vertica documentation](https://my.vertica.com/docs/7.1.x/HTML/index.htm)
1. [APPROXIMATE_COUNT_DISTINCT](http://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/SQLReferenceManual/Functions/Aggregate/APPROXIMATE_COUNT_DISTINCT.htm)
1. [Create a Table Like Another](https://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/AdministratorsGuide/Tables/CreatingATableLikeAnother.htm)
1. [V_MONITOR.QUERY_PLAN_PROFILES](https://my.vertica.com/docs/7.1.x/HTML/Content/Authoring/SQLReferenceManual/SystemTables/MONITOR/QUERY_PLAN_PROFILES.htm) system table.
1. [Profiling Query Plans](https://my.vertica.com/docs/7.1.x/HTML/Content/Authoring/AdministratorsGuide/Profiling/ProfilingQueryPlanProfiles.htm).
1. [PROFILE](https://my.vertica.com/docs/7.1.x/HTML/Content/Authoring/SQLReferenceManual/Statements/PROFILE.htm) statement.
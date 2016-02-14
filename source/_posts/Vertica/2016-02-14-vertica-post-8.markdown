---
layout: post
title: "WITH clause in Vertica SQL"
date: 2016-02-03 00:50:48 -0800
comments: true
categories: 
- Vertica
- SQL
- SQLite
---

Vertica SQL supports `WITH` clause, as documented [here](https://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/AnalyzingData/Queries/WITHClausesInSELECT.htm).
`WITH` syntax as a standard is only defined in [SQL-99](https://en.wikipedia.org/wiki/SQL:1999), also called *Common Table Expressions*. Therefore, `WITH` clause is a fairly recent feature of SQL dialects. For example: `WITH` clause support is only added into SQLite since Feb 2014.

In summary, the `WITH` clause allows us to arrange sub-queries in a SQL query in order of human logic. This will make our query much easier to read: we can read from top to bottom like reading a novel (i.e., [literate programming](https://en.wikipedia.org/wiki/Literate_programming)). 

For example, we can look into the following `SELECT` query:

``` sql Hard to read
SELECT * FROM (
  SELECT *,
  row_number() OVER (PARTITION BY customer_id ORDER BY last_modify_date DESC) AS rank 
  FROM stg_customer
) t1 where t1.rank =1
```

Before `WITH` clause, SQL scripts are usually hard to read due to nesting of sub-queries. 
To understand a SQL statement, we have to find and understand the innermost sub-query first and start working from inside out.
In addition, as shown in the first example, name `t1` following the sub-query makes reading harder, even with the well-chosen names.
The longer the innqer query gets, the more likely the name for that query is pushed out of sight despite the fact that it is important to see an intention revealing name before reading such inner query.

The above example can be made easier to read using `WITH` clause as follows:

``` sql Easy to read
WITH t1 AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_id 
                                  ORDER BY last_modify_date DESC) AS rank 
    FROM stg_customer
)
SELECT * FROM t1
WHERE t1.rank = 1;  
```

As the second example demonstrates, `WITH` clause solves two problems: 1) names come first, 2) sub-queries are unnested.
The `WITH` clause puts the name above the code, like declaring a function with code in the sub-query.
We can pick a meaningful, intention revealing name for it and we can refer to that "function" in the following sub-queries in the same `WITH` clause. 
Moreover, the most powerful impact of `WITH` clause is that sub-queries can be unnested to follow the order and flow of developers' thought.
We can define multiple queries for multiple steps, and each of them can refer to the *previously* defined queries in the same `WITH` clause.

The following example desmonstrates the power of [literate programming](https://en.wikipedia.org/wiki/Literate_programming) in SQL, enabled by `WITH` clause:

``` sql Traffic classification
SELECT
```

It would be hard to write such an easy to read query using only nested sub-queries.
The ease of reading is a combination of top-down code structure and meaningful block names at the right places (before code blocks).

Without `WITH` clause, we used to create `TEMPORARY TABLES` in Vertica to save the immediate steps.
Now, we have a native SQL solution in `WITH` clause and it is actually a more powerful technique to create subqueries.
---
layout: post
title: "WITH clause in SQL"
date: 2016-02-03 00:50:48 -0800
comments: true
categories: 
- Vertica
- SQL
---

I am pleasantly surprised that Vertica SQL supports `WITH` clause, as documented [here](https://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/AnalyzingData/Queries/WITHClausesInSELECT.htm).
`WITH` syntax as a standard is only defined in [SQL-99](https://en.wikipedia.org/wiki/SQL:1999), also called *Common Table Expressions*. 
Therefore, I do not usually expect `WITH` clause since it is a fairly recent feature in most SQL dialects. 
For example: `WITH` clause support is only added into SQLite since Feb 2014.

In summary, the `WITH` clause allows us to arrange sub-queries in a SQL query in order of human logic. 
This will make our query much easier to read: we can read from top to bottom like reading a story (i.e., [literate programming](https://en.wikipedia.org/wiki/Literate_programming)). 

<!--more-->

For example, we can look into the following `SELECT` query:

``` sql Hard to read
SELECT * FROM (
  SELECT *,
  row_number() OVER (PARTITION BY customer_id ORDER BY last_modify_date DESC) AS rank 
  FROM stg_customer
) sorted_by_modify_date where sorted_by_modify_date.rank =1
```

Before `WITH` clause, SQL scripts are usually hard to read due to nesting of sub-queries. 
To understand a SQL statement, we have to find and understand the innermost sub-query first and start working from inside out.
In addition, as shown in the first example, name `sorted_by_modify_date` following the sub-query makes reading harder, even with meaningful names.
The longer the inner query gets, the more likely the name for that query is pushed out of sight despite the fact that it is important to see an intention revealing name before reading such inner query.

The above example can be made easier to read using `WITH` clause as follows:

``` sql Easy to read
WITH sorted_by_modify_date AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY customer_id 
                                  ORDER BY last_modify_date DESC) AS rank 
    FROM stg_customer
)
SELECT * FROM sorted_by_modify_date
WHERE sorted_by_modify_date.rank = 1;  
```

As the second example demonstrates, `WITH` clause solves two problems: 1) names come first, 2) sub-queries are un-nested.
The `WITH` clause puts the name above the code, like declaring a function with code in the sub-query.
We can pick a meaningful, intention revealing name for it and we can refer to that "function" in the following sub-queries in the same `WITH` clause. 
Moreover, the most powerful impact of `WITH` clause is that sub-queries can be un-nested to follow the order and flow of developers' thoughts.
We can define multiple queries for multiple steps, and each of them can refer to the *previously* defined queries in the same `WITH` clause.

The following example demonstrates the power of [literate programming](https://en.wikipedia.org/wiki/Literate_programming) in SQL, enabled by `WITH` clause:

``` sql Traffic classification of a Music website
WITH Total_Traffic AS
(
    SELECT temp.* from temp as clickstream_data
    where .... -- filtering
)
, Rock_Music as
(
    select * from Total_Traffic
    WHERE lower(evar28) LIKE 'rock_mus%'
)
, Instrumental_Music as
(
    select * from Total
    WHERE evar28 LIKE '%[ins_mus]%'
)
, Defined_Traffic as
(
    select * from Rock_Music
    UNION
    select * from Instrumental_Music
)
select traffic_date_key
, count(distinct visitor_id) as unique_visitor
from Defined_Traffic 
group by traffic_date_key
```

The purpose of this query is to find the daily number of "Defined" unique visitors from clickstream data. 
Finding daily total unique visitors from Clickstream data is easy and, by subtracting "Defined" numbers from "Total" numbers, we can find the "Unknown" traffic numbers that help determine marketing decisions.
Note that the total "defined" unique visitor count is NOT equal to sum of all unique visitor counts from each classification (e.g., "Rock" + "Instrumental") since some visitors will listen to both Rock and Instrumental music on the website.

It would be hard, if not impossible, to write such query using only nested sub-queries and achieve the same readability.
The ease of reading is from a combination of top-down code structure and meaningful block names before code blocks, both are properties of `WITH` clause.

In the past, without `WITH` clause, we used to create `TEMPORARY TABLES` in Vertica to save the immediate steps.
Now, we have a native SQL solution in `WITH` clause and a more powerful technique to create sub-queries.

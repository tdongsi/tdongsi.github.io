---
layout: post
title: "Analytic functions in MySQL"
date: 2016-08-17 23:12:54 -0700
comments: true
categories: 
- SQL
- Vertica
- MySQL
---

MySQL has traditionally lagged behind in support for the SQL standard.
However, from my experience, MySQL is often used as the sandbox for SQL code challenges and interviews.
If you are used to work with [Vertica SQL](https://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/SQLReferenceManual/SQLReferenceManual.htm), writing SQL statements in MySQL can be challenging exercises, NOT necessarily in a good way.

### WITH clause

As discussed in this [blog post](/blog/2016/02/03/vertica-6-with-clause/), `WITH` clause syntax, also known as *Common Table Expressions* (CTE), is thankfully supported in Vertica.
In summary, `WITH` clause allows us to arrange sub-queries, usually intermediate steps, in a complex SQL query in sequential, logical order.
This will make the complex queries easier to compose and read: we can write steps by steps of the query from top to bottom like a story (i.e., [literate programming](https://en.wikipedia.org/wiki/Literate_programming)).
Unfortunately, `WITH` clause is not supported by MySQL although this feature has been requested since [2006](https://bugs.mysql.com/bug.php?id=16244).
There are [work-around](http://guilhembichot.blogspot.fr/2013/11/with-recursive-and-mysql.html) for MySQL's lack of CTE, but the easiest way is probably to revert back to using nested subqueries.

Personally, lack of `WITH` clause support in MySQL is my greatest hindrance as I often ended up writing queries using `WITH` clauses as first draft before rewriting those queries using nested subqueries.
This might look really clumsy in SQL interviews even though writing SQL codes with CTE instead of subqueries is the recommended practice.

### Analytical functions

Another regrettable hindrance when working in MySQL is its lack of analytical functions such as `row_number`, `rank` and `dense_rank`.
Those [analytical functions](https://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/SQLReferenceManual/Functions/Analytic/AnalyticFunctions.htm) are supported in Vertica.
The difference between these three functions can be a bit subtle, and would be best described in the following example:

``` sql Example of row_number, rank, and dense_rank functions
SELECT customer_name, SUM(annual_income),
ROW_NUMBER () OVER (ORDER BY TO_CHAR(SUM(annual_income),'100000') DESC) row_number, 
RANK () OVER (ORDER BY TO_CHAR(SUM(annual_income),'100000') DESC) rank, 
DENSE_RANK () OVER (ORDER BY TO_CHAR(SUM(annual_income),'100000') DESC) dense_rank 
FROM customer_dimension
GROUP BY customer_name
LIMIT 15;
```

``` plain Example output
    customer_name    |  sum  | rank | dense_rank 
---------------------+-------+------+------------
 Brian M. Garnett    | 99838 |    1 |          1
 Tanya A. Brown      | 99834 |    2 |          2
 Tiffany P. Farmer   | 99826 |    3 |          3
 Jose V. Sanchez     | 99673 |    4 |          4
 Marcus D. Rodriguez | 99631 |    5 |          5
 Alexander T. Nguyen | 99604 |    6 |          6
 Sarah G. Lewis      | 99556 |    7 |          7
 Ruth Q. Vu          | 99542 |    8 |          8
 Theodore T. Farmer  | 99532 |    9 |          9
 Daniel P. Li        | 99497 |   10 |         10
 Seth E. Brown       | 99497 |   10 |         10
 Matt X. Gauthier    | 99402 |   12 |         11
 Rebecca W. Lewis    | 99296 |   13 |         12
 Dean L. Wilson      | 99276 |   14 |         13
 Tiffany A. Smith    | 99257 |   15 |         14
```

Unfortunately, those functions are not supported in MySQL.


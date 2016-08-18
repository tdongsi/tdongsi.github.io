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
Being used to work with [Vertica SQL](https://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/SQLReferenceManual/SQLReferenceManual.htm), writing SQL statements in MySQL can be very challenging exercises, NOT necessarily in a good way.

### WITH clause

As discussed in this [blog post](/blog/2016/02/03/vertica-6-with-clause/), `WITH` clause syntax, also known as *Common Table Expressions* (CTE), is supported in Vertica.
In summary, `WITH` clause allows us to arrange sub-queries, usually itermediate steps, in a complex SQL query in sequential, logical order.
This will make the complex queries easier to compose and read: we can write steps by steps of the query from top to bottom like a story (i.e., [literate programming](https://en.wikipedia.org/wiki/Literate_programming)).
Unfortunately, `WITH` clause is not supported by MySQL although this feature has been requested since [2006](https://bugs.mysql.com/bug.php?id=16244).
There are [work-around](http://guilhembichot.blogspot.fr/2013/11/with-recursive-and-mysql.html) for MySQL's lack of CTE, but the easiest way is probably to revert back to using nested subqueries.

Personally, lack of `WITH` clause support in MySQL is the greatest hindrance as I often ended up writing queries using `WITH` clauses as first draft before rewriting those queries using nested subqueries.
This might look really clumsy in SQL interviews.

### Analytical functions

Analytical functions: row_number, rank, dense_rank.

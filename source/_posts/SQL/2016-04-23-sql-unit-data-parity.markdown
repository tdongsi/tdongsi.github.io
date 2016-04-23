---
layout: post
title: "(Pt. 7) Extending for data parity checks"
date: 2016-04-17 16:39:19 -0700
comments: true
categories: 
- Math
- SQL
- Automation
- Testing
- Vertica
- Java
---

For overview, see [here](/blog/2016/03/16/sql-unit-overview/).

TODO: Introduction

### Background of data parity checks

Recently, I had to do lots of data parity checks to verify changes in Extract-Load processes (i.e., EL with no Transform).
In those data parity checks, we want to make sure data in some columns of two tables (i.e., two projections) must be the same.
In other words, we want to verify if the two following queries return completely matching rows and columns:

``` plain Data parity checks
select col1, col2 from old_table_name

matches
 
select col3, col4 from new_table_name
```

The straight-forward test would be get all rows and columns of those two projections, and perform equality check one by one. 
It would be very time-consuming to write and execute such test cases in Java and TestNG.
Even when the query returns can be managed to be within the memory limit, it is still time-consuming to do data transfer for the two SQL returns, join the columns to prepare for comparison row by row. 
Moreover, note that these expensive operations are carried out on the client side, the test execution machine (e.g., our computer).

The more efficient way for this data parity check is to use these two SQL test queries, using the test blocks shown in [this post](/blog/2016/03/28/sql-unit-test-runner/):

``` plain Test blocks for data parity check
/* @Test
{
    "name" : "parity_check",
    "query" : "select col1, col2 from old_table_name
                EXCEPT
                select col3, col4 from new_table_name
                limit 20",
    "expected" : ""
}
*/

/* @Test
{
    "name" : "parity_check_reverse",
    "query" : "select col3, col4 from new_table_name
                EXCEPT
                select col1, col2 from old_table_name
                limit 20",
    "expected" : ""
}
*/
```

The two SQL test queries is based on the following [set theory identities](https://en.wikipedia.org/wiki/Algebra_of_sets):

<p><span class="math display">\[A = B \Leftrightarrow A \subseteq B \mbox{ and } B \subseteq A\]</span></p>

<p><span class="math display">\[A \subseteq B \Leftrightarrow A \setminus B = \varnothing\]</span></p>

If `Table_A EXCEPT Table_B` returns nothing, it indicates that data in `Table_A` is a subset of data in `Table_B`. Similarly for `Table_B EXCEPT Table_A`. Therefore, if two test cases pass, it means that the data in `Table_A` is equal to the data in `Table_B`.

Using these two queries, we shift most of computing works (`EXCEPT` operations) to the Vertica server side. 
Moreover, in most of the cases when the tests pass, the data transfer would be usually minimal (zero row).
In summary, this will save us lots of computation time (since Vertica server machine is usually much more powerful), data transfer time, and assertion check time.

The `limit 20` clause is also for minimizing data transfer and local computation works.
When the expected return of the test SQL query is nothing (i.e., `"expected" : ""`), we should always add LIMIT clause to the query. 
This will save some test-running time and make your log file cleaner when something went wrong and caused the test to fail.
For example, if there are 100000 additional, erroneous rows of data in `new_table_name` for some reason, the test case "parity_check_reverse" will fail. 
However, instead of transferring 100000 rows, only 20 of those will be sent to the local host (test machine), thanks to the `LIMIT` clauses. 
In addition, the log file of the Test Runner will NOT be flooded with 100000 rows of erroneous data while 20 sample rows are probably enough to investigate what happened.

### Extending SQL Test Runner

Add new JSON.

Use the old code to handle the old POJOs.
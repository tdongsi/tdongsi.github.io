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

As an example to discussion in [this post](/blog/2016/04/16/sql-unit-extension/), I will discuss how I recently added a new functionality to handle a new kind of tests.

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
Moreover, note that these expensive operations are carried out on the client side, the test execution machine (e.g., our computers).

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

If `Table_A EXCEPT Table_B` query returns nothing, it indicates that data in `Table_A` is a subset of data in `Table_B`. 
Similarly for `Table_B EXCEPT Table_A` query. 
Therefore, if two test cases pass, it means that the data in `Table_A` is equal to the data in `Table_B`.

Using these two queries, we shift most of computing works (`EXCEPT` operations) to the Vertica server side, which is faster since Vertica server cluster is usually much more powerful than our individual computers. 
Moreover, in most of the cases when the tests pass, the data transfer would be usually minimal (zero row).
In short, this will save us lots of computation time, data transfer time, and assertion check time.

The `limit 20` clause is also for minimizing data transfer and local computing works.
When the expected return of the test SQL query is nothing (i.e., `"expected" : ""`), we should always add LIMIT clause to the query. 
When something went wrong and caused the test to fail, this will save some waiting time and make your log file cleaner .
For example, if there are 100000 additional, erroneous rows of data in `new_table_name` for some reason, the test case "parity_check_reverse" will fail. 
However, instead of transferring 100000 rows, only 20 of those will be sent to the local host (test machine), thanks to the `LIMIT` clauses. 
In addition, the log file of the Test Runner will NOT be flooded with 100000 rows of erroneous data while 20 sample rows are probably enough to investigate what happened.

### Extending SQL Test Runner

If we only need to do a few simple data parity checks, a few ("name", "query", "expected") test blocks as shown above will suffice.
However, there were tens of table pairs to be checked and many tables are really wide, with about 100 columns.
For wide tables, for easy investigation if data parity checks fail, we check data in group of 6-10 columns.
Writing test blocks like above can become a daunting task, and such test blocks are becoming harder to read.
Therefore, I create a new test block construct that is more friendly to write and read, as shown below.

``` plain New test block
/* @Test
{
    "name" : "parity_check",
    "query" : "select col1, col2 from old_table_name",
    "equal" : "select col3, col4 from new_table_name"
}
*/
```

Under the hood, this test block should be equivalent to the two test blocks shown in the last section.
That is, from the two projection queries found in "query" and "equal" clauses, the SQL Test Runner will generate two test blocks with SQL test queries as shown above (using `EXCEPT` operations).

Implementation of this new feature is summarized in the following steps:

1. Define new JSON block. 
1. Define new POJO (named `NameQueryEqual`) that maps to new JSON block.
1. Create a new class (named `NewHandler` for easy reference) that implements TestStrategy interface to handle the new POJO. Specifically:
   1. From `NameQueryEqual` POJO, generate two `NameQueryExpected` POJOs with relevant queries (using `EXCEPT` operations).
   1. Reuse the old TestHandler class to process two `NameQueryExpected` POJOs.

For step 1, the new JSON block is already defined as above. 
From JSON, the corresponding POJO in step 2 can be easily defined:

``` java
/**
 * POJO for JSON test block comparing two projections
 * 
 * @author tdongsi
 */
public class NameQueryEqual {
	// Test name.
	public String name;
	// File lists to run
	public List<String> file;
	// Test query in SQL
	public String query;
	// Equivalent query in SQL
	public String equal;
}
```

For step 3, as emphasized in the [last post](/2016/04/16/sql-unit-extension/), we should not modify the old test runner to handle this new POJO.
Instead, we should create a new class `NewTestHandler` that implements TestStrategy interface to handle the new POJO and create a new test runner that uses the new TestStrategy (Strategy pattern).
The implementation of the new test block handler is not really complex, thanks to modular structure of SQL Test Runner.
We only need to extract the two projections from `NameQueryEqual` POJO, generate two `EXCEPT` queries for those two projections (with some `LIMIT` clauses), and create two  `NameQueryExpected` POJOs for those test queries.
Since we already have a TestHanlder class that can run and verify those `NameQueryExpected` POJOs, we only need to include a TestHandler object into the `NewTestHandler` class and delegate handling `NameQueryExpected` POJOs to it.
Note that this is recommended over subclassing `TestHandler` to include new code for handling the new `NameQueryEqual` POJO (i.e., "composition over inheritance").

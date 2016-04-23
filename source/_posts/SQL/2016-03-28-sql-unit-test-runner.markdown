---
layout: post
title: "(Pt. 2) SQL Test Runner"
date: 2016-03-28 23:42:09 -0700
comments: true
categories: 
- SQL
- Automation
- Testing
---

For overview, see [here](/blog/2016/03/16/sql-unit-overview/).

In this blog post, I shows some example test cases using the SQL Test Runner, introduced in "Level 3" in [this post](/blog/2016/03/20/sql-unit-functional-tests/).
As it is mentioned in that post and will be illustrated here, many decisions are based on my testing philosophy: **prioritize readability of tests when possible**.

### Overview

In this test framework, a test block is defined in the following format: comment block opening `/*` followed by `@Test`, and a JSON object with some specified keys in the next subsection, closed by comment block closing `*/`.

``` plain Example
/* @Test
{
  "name":"test_count",
  "query":"select count(1) from dim_product",
  "expected":"5"
}
*/
```

The SQL Test Runner will:

1. Pick up the test blocks, annotated as above.
1. Extract the JSON to retrieve the test query and expected output.
   * As shown in [this](/blog/2016/04/10/sql-unit-incremental-data-update/) and [this](/blog/2016/04/16/sql-unit-extension/), we can add custom JSON for different testing needs.
1. Send the query to the database, and get the actual output from the database.
1. Compare actual output with the expected output, raise `AssertionError` if needed.
   * Note that the Test Runner can either exit immediately upon `AssertionError` or run all test queries and list all `AssertionError`s at the end.
   
As shown in the following example, we can add newlines and whitespaces to the test query (i.e., value in "query" clause) for aligning and formatting the query, especially when the query is long and complex.

``` plain Example complex test query
/* @Test
{
  "name" : "check_traffic",
  "query" : "WITH Total_Traffic AS
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
      group by traffic_date_key",
  "expected" : "2016-03-16 123"
}
*/
```

Note that in pure JSON, newlines are NOT allowed and the above JSON when deserializing directly will report syntax errors.
However, as you can see, newlines and whitespaces greatly improve readability of the complex test query.
Therefore, I add a pre-processing step in SQL Test Runner to replace all whitespace characters (`\s+`) in test block with a single space (` `).
The additional computation is minimal and it is quite a good trade-off for much better *readability* of the test scripts.

### Example usage

This section list some simple examples to illustrate some standard, common usage of test blocks.

``` plain Compare test query's output with expected output
/* @Test
{
   "name":"test_count",
   "query":"select count(*) from dim_product;",
   "expected":"5"
}
*/
```

Multiple rows, multiple columns can also be used as expected output.
All output of the test query will be normalized to String before comparison.
For **readability**, we can add whitespaces and newlines into expected output string to align rows and columns.
Before comparison, the actual and expected output is pre-processed to replace all whitespace characters (`\s+`) with a single space (` `).

``` plain Expected output with multiple rows, multiple columns
/* @Test
{
 "name":"test_data",
 "query":"select price, product from dim_product order by product_key;",
 "expected":"10 Chair
              20 Table
              30 Twin Bed
              40 King Bed"
}
*/
```

In many situations, the row count of a table is not definitely known.
However, we still know that its row count should fall in some number range, such as more than 100 or less than one million.
The Test Runner allows you to add some simple logical expression in "expected" clause.
It is tester's responsibility to make sure the test query returns some numbers and the logical expression makes sense.

``` plain Expected output with logical expression
/* @Test
-- This is same as "expected" : "5"
{
   "name":"test_count_operator_equal",
   "query":"select count(*) from dim_product;",
   "expected":"== 5"
}
*/

/* @Test
-- There must be some entries, at least 10, in the table.
-- Evaluated as: actual value > 10
{
   "name":"test_count_operator",
   "query":"select count(*) from dim_product;",
   "expected":"> 10"
}
*/
```

Note that in the examples above, inline comments can be added into test block using SQL's `--` inline comment notation.
In addition to "name", "query" and "expected", you can add a list of script files to be executed in a "file" clause, as shown in the following example.
The test query will be executed after all the scripts have been executed.

``` plain "file" key to execute shared statements
/* @Test
{
    "name":"test_file_multiple",
    "file":["testscript/sql/vertica/dim_product_table_drop.sql", 
            "testscript/sql/vertica/dim_product_table_create.sql"],
    "query":"select count(1) from dim_product;",
    "expected":"0"
}
*/
```

In practice, you should use the above "file" clause for:

* Adding more complicated setup statements or tests in external test scripts. Example: creating and populating tables for synthetic data.
* Reusing the most common tests (e.g., count, constraint checks).
* Making the original test scripts less cluttered with repeated SQL queries or statements.

For reference, the JSON test blocks are mapped into POJOs by the SQL Test Runner, defined by the following NameQueryExepected class: 

``` java
/**
 * POJO for simple JSON test block
 * 
 * @author tdongsi
 */
public class NameQueryExpected {
	// Test name
	public String name;
	// File lists to run
	public List<String> file;
	// Test query in SQL
	public String query;
	// Expected output of the test query above
	public String expected;
}
```

Note that all attributes in POJO are optional, NOT required to be defined at all time.
The most commonly used is ("name", "query", "expected") combination, but you can see others such as the following: 

``` plain Some other uses
/* @Test
-- Just want to make sure this query can be executed. Outputs can vary.
{
    "name": "test_ignore_output",
    "query": "select * from dim_product order by product_key;",
}
*/

/* @Test
-- Run some setup scripts
{
    "name":"test_file_multiple",
    "file":["testscript/sql/vertica/dim_product_table_drop.sql", 
            "testscript/sql/vertica/dim_product_table_create.sql"]
}
*/
```

### Advanced usage

Another variant to NameQueryExpected POJO is NameQueryEqual POJO, defined as follows:

``` java 
/**
 * POJO for JSON test block comparing two projections
 * 
 * @author tdongsi
 */
public class NameQueryEqual {
	// Test name. NOTE: This is ignored when comparing two POJOs.
	public String name;
	// File lists to run
	public List<String> file;
	// Test query in SQL
	public String query;
	// Equivalent query in SQL
	public String equal;
}
```

As explained in more details in [this post](/2016/04/17/sql-unit-data-parity/), "equal" is a recently added capability to easily compare two tables or projections from tables.

``` plain "equal" clause
/* @Test
{
    "name":"test_data_equivalent",
    "query":"select product_key, cost from dim_product WHERE ...;",
    "equal":"select product_key, cost from dim_inventory WHERE ...;"
}
*/
```

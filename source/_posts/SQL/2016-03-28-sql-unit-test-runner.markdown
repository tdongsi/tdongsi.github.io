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
   * Note that the TestRunner can either exit immediately upon `AssertionError` or run all test queries and list all `AssertionError`s at the end.
   
TODO: new line in JSON

### Example usage

This section list some *lame* examples to illustrate some standard, common usage of test blocks.

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
The actual and expected output is pre-processed to replace all whitespace characters (`\s+`) with a single space (` `).

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
However, we still know that its row count should fall in some number range, such as larger than 100.
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

``` plain Some other uses
/* @Test
-- Just want to make sure the query can execute
{
    "name":"test_ignore_output",
    "query":"select * from dim_product order by product_key;",
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

As explained in more details in this post (TODO: add link), "equal" can be used to compare two projections.

``` plain "equal" clause
/* @Test
{
    "name":"test_count_equivalent",
    "query":"select product_key, cost from dim_product WHERE ...;",
    "equal":"select product_key, cost from dim_inventory WHERE ...;"
}
*/
```


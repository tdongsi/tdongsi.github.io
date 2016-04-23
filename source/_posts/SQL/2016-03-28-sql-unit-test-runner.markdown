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
   * Note that the TestRunner can either exit immediately or run all test queries and list all `AssertionError`s at the end.
   
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


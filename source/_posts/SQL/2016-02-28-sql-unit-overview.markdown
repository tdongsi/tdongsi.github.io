---
layout: post
title: "SQL testing in Data Marts"
date: 2016-03-15 23:43:09 -0800
comments: true
published: true
categories: 
- SQL
- Automation
- Testing
---

Data mart is a smaller version of a data warehouse, help driving business decisions of a department in a large company.
The journey of automated testing in Data Mart projects is tough: most of the business logics are implemented in SQL scripts.
We don't even know how to test Data Marts' functionality from the beginning: how do I know if the SQL script works or if data is correct.
Even worse, we don't know what defines "unit testing" in Data Mart projects and could not enforce it on data engineers and scientists (the developers).
We need an automation framework so that data engineers and quality engineers can start creating automated unit tests, instead of depending on data analysts to verify data marts manually.

<!--
Note that SQL scripts is only a small part of ETL processes. There are other scripts such as bash, python scripts, Java programs, and/or commerical tools such as Tidal that move data and execute those SQL scripts.
-->

### Functional testing for Data Mart projects

We gradually figured out automated functional testing first and continued to improve it. 
This [blog post](/blog/2016/03/16/sql-unit-functional-tests/) documents the journey of automated functional testing, the rationale after each cycle of its evolution.

### SQL Test Runner

In the latest iteration of automated testing, supporting Java code is abstracted into a SQL Test Runner. 
Quality engineers and data analysts can now write test queries and assertions in more readable test blocks.
This [blog post](/blog/2016/03/28/sql-unit-test-runner/) provides some examples. 
As you can see, many decision-making during impelmentation is based on my motto: **prioritize test readability** when it makes sense.

### Incremental data update

One of biggest challenges in SQL testing is "incremental data update" in ETL scripts.
Challenges in functional testing those motivates me to create a test framework to allow adding unit-like tests for those ETL scripts.
This [blog post](/blog/2016/04/10/sql-unit-incremental-data-update/) discusses "incremental data update" and how it should be tested as a number of unit tests.

### Unit testing

What changes I make.

1. Mix of SQL code and test blocks.
1. New JSON block to run ETL script using VSQL

Running ETL script through JDBC is probably not a good idea.

Requirements of unit tests:
[SBG Datamart - Unit tests]

Readability:
Not all analysts and developers are comfortable with Java. But nobody knows about the data better than analysts.
If the data analysts are able to read unit test scripts and confirm the expectation, QEs will save lots of time translating business requirements from SQL/Java tests.

### Single-node VM

Remove KSAFE.

Add a new test.

Revert in Git.

### Adding  unit test

Show SBG strategy.

### Functional tests vs Unit tests

This [blog post](/blog/2016/04/14/sql-unit-vs-functional/) recap the above sections by highlighting the difference between these two in the context of Big Data projects.
It should be noted that two groups of tests complement each other in assuring quality and functionality of Big Data projects.

### Extending SQL Test Runner

Template Method design pattern
Strategy pattern

#### Example: Kobayashi testing

Add a new JSON block.






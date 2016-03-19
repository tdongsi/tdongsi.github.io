---
layout: post
title: "SQL Unit testing"
date: 2016-03-15 23:43:09 -0800
comments: true
published: false
categories: 
- SQL
- Automation
- Testing
---

How to tell the story.
<!--
Note that SQL scripts is only a small part of ETL processes. There are other scripts such as bash, python scripts, Java programs, and/or commerical tools such as Tidal that move data and execute those SQL scripts.
-->

### Brief overview of Data Mart functional testing

Introduction
Data mart is a smaller version of data warehouse, help driving business decisions of a department in a large company.

Level 0
Level 1
Level 2
Level 3

Functional tests.

Choose readability over grammar.

Links:

1. https://wiki.intuit.com/display/iea/Improve+readability+of+functional+tests+with+SQL+Test+Runner

#### SQL Test Runner

POJO
Examples.

### Incremental update testing

What incremental update?

How to test incremental update?
You collect a set of three sets of data.

1. Manually set up the data.
1. Manually run ETL.
1. Most of the time, the difference in data between two dates are enough to check corner cases.
1. Run ETL and tests on 6+ million records when 99.99% of data is the same.

It takes lots of time to manually set up and run ETLs: about 4 hours for a proper sequence.
It takes lots of mental energy to do it right.
For very little return. After running it, you still don't know if ETL won't break if data is updated in another column.
I have every single time of doing it.

1. I only need a small number of records.
1. I can create synthetic data to force rare logic branches and corner cases.
1. Automatic setup.
1. Automatic running ETL under test.

Guess what? This is exactly unit testing.

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

### Extending SQL Test Runner

Template Method design pattern
Strategy pattern

#### Example: Kobayashi testing

Add a new JSON block.






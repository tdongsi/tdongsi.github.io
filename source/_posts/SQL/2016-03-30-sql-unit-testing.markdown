---
layout: post
title: "(Pt. 4) SQL unit testing"
date: 2016-04-12 17:45:42 -0700
comments: true
categories: 
- SQL
- Vertica
- Automation
- Testing
---

Navigation: [Overview](/blog/2016/03/16/sql-unit-overview/), 
[Pt 1](/blog/2016/03/20/sql-unit-functional-tests/), 
[Pt 2](/blog/2016/03/28/sql-unit-test-runner/), 
[Pt 3](/blog/2016/04/10/sql-unit-incremental-data-update/).

<!-- 
Changes I made:
1. Mix of SQL code and test blocks.
1. New JSON block to run ETL script using VSQL

I would also discuss some guidelines of unit testing for ETL and when it makes sense to focus.

Running ETL script through JDBC is probably not a good idea.

Requirements of unit tests:

Readability:

#### Single-node VM

Remove KSAFE.

Add a new test.
  
Revert in Git.

#### Adding  unit test

Show SBG strategy.

#### Other usages

You can insert into the ETL script to verify step by step.
However, there is only one set of mock data. 
In unit testing, you might want multiple setup of mock data for different scenarios.
=> the other way is actually more flexible

Assumptions:

1. No ;
1. ETL is simple enough: the same tables are not updated and transformed multiple times in multiple steps. 


-->

TODO indefinitely.

The idea is to use a local Vertica VM as a sandbox test environment. 
It could be a [single cluster VM](/blog/2016/01/10/find-and-replace-a-string-in-multiple-files/) or [three-node cluster VM](/blog/2016/03/12/set-up-three-node-vertica-sandbox-vms-on-mac/).

The following changes in SQL Test Runner are critical to enable unit testing:

1. Mix of SQL code and test blocks: We can use SQL code to do necessary data setup before running SQL queries and verifying expected outputs.
1. New test block to run ETL script using VSQL CLI: The ETL scripts are considered (large) classes/functions under test, and this new kind of test block simplify running those "functions" again and again with different synthetic data. Running using VSQL CLI is required since we execute ETL scripts in production using that tool.
1. Automated execution of DDL/DML files for loading other static dimension tables.

TODO
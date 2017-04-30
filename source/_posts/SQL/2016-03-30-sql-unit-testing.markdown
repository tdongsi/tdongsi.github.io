---
layout: post
title: "(Pt. 4) SQL unit testing"
date: 2016-04-12 17:45:42 -0700
comments: true
published: false
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

In the following example, two `INSERT` statements is used to set up data in two input staging tables.
They are followed by a new test block to run the ETL script.
After the ETL is executed, the output data, `email_address` column for example, in the target dimension table is verified using the [standard test block](/blog/2016/03/28/sql-unit-test-runner/).
Other static dimension tables such as `dim_country` that the ETL script `my_etl.sql` depends on, can be created and populated using Java code.

``` sql Example unit test
/****************************
* Day 1
****************************/

INSERT INTO stg_company_id (company_id,last_modify_date,region_id)
VALUES (123,current_timestamp-19,'US');

INSERT INTO stg_company_contact (company_id,master_email,last_modify_date)
VALUES (123,'before@mockdata.com', current_timestamp-15);

/* @Test
-- First ETL run
{
 "name" : "Day1_etl_run",
 "vsql_file" : ["repo_home/sql/my_etl.sql"]
}
*/

/* @Test
{
 "name" : "Day1_check_email_address",
 "query" : "select company_id, email_address from dim_company",
 "expected" : "123 before@mockdata.com"
}
*/
```

``` java Calling unit test script
@BeforeClass
public void setup() {
    testRunner = new SqlTestRunner(getJdbcConnection());
    setupSchema("UNITTEST");
}

@AfterClass
public void teardown() {
    teardownSchema("UNITTEST");
}

@Test(enabled = true)
public void validate_dim_region() throws Exception {
        testRunner.runScript("unittests/etl_incremental_update_email.test");
}
```

For full unit test script, see [here](/blog/2016/04/10/sql-unit-incremental-data-update/).
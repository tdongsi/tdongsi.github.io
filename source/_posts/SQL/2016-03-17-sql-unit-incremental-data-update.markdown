---
layout: post
title: "(Pt. 3) Testing Incremental data update"
date: 2016-04-10 17:46:40 -0700
comments: true
published: true
categories: 
- SQL
- Testing
- Automation
---

For overview, see [here](/blog/2016/03/16/sql-unit-overview/).

One of challenges in SQL testing is "incremental data update" in ETL scripts.
Challenges in functional testing motivates me to create a test framework to add unit-like tests for those ETL scripts.

### Incremental data update

In the last [blog post](/blog/2016/03/16/sql-unit-functional-tests/), I go over evolution of functional testing in data mart projects.
In functional tests, we deploy the data marts, run all the DDL, DML and ETL scripts, and, then, execute a bunch of SQL test queries to validate the tables.

That kind of testing would be sufficient if the inputs of the ETL are snapshot tables: data extracted by the ETL scripts are the latest snapshot of the data.
Preparing this snapshot might be expensive, especially for daily ETLs, since those tables have to be truncated and reloaded with latest data.
This can be every inefficient since out of millions of records for twenty years of historical data, less than one percent of those will be updated over a day interval.
Therefore, for performance reasons, the ETLs usually perform **incremental data update**. 
Some characteristics of "incremental data update" are as follows:

1) Only updated records are incrementally appended into some tables, used for staging purpose (a.k.a. staging tables). 
These tables will be used as input for those ETLs with incremental update.
For example, let's say there is a company record with ID = 123 and some attribute such as master email `before@mock.com` on Day 1.
On Day 2, the company email could be udpated to `after@mock.com`. 
The original record of company 123 with `before@mock.com` is not necessarily removed from the staging table.
Instead, a new row with updated data (ID = 123, email = `after@mock.com`) is appended into the staging table.

2) To keep the size of input tables and ETL running time bounded, we usually keep only a number of days worth of data in the staging tables.
In other words, any records older than some `D` days are truncated from those staging tables.
For example, after `D = 7` days since Day 2, if the company `ID = 123` has no update, its records will be removed from the staging tables.
Note that, after being truncated, that company `ID = 123` can be re-inserted into the staging table if some of its attribute is updated. 

**Risks**: The ETLs with incremental data update are usually much more complex.
Obviously, one risk of running ETL with incremental data update is duplicate records: we could have multiple rows for the same company `ID = 123`. 
In standard approach with snapshot, each record is almost guaranteed unique on primary key, meaning only one row with company `ID = 123`.
On the other hand, when data for company `ID = 123` are truncated from the staging tables after `D` days (0 row), it simply means that there is no update to that company during the last `D` days.
It means that the company should not be removed from the destination tables of the ETL even though the input staging tables contain no such row for `ID = 123`.
The following example scenario illustrates the challenge and complexity of ETLs with incremental data update.

### Example scenario

For sliding window of one week data `D = 7` in the staging tables `stg_company_id` and `stg_company_contact`, the company with `ID = 123` may have its email address updated like this:

* Day 1
  * `stg_company_id` -> ID: 123, region: US.
  * `stg_company_contact` -> ID: 123, email: before@mockdata.com. (same company)
* Day 3
  * Email updated to after@mockdata.com in `stg_company_contact`.
  * `stg_company_id` has one row with ID = 123.
  * `stg_company_contact` has two rows with ID = 123.
* Day 10
  * Data truncated from `stg_company_contact` as there is no update.
  * Data is also truncated from `stg_company_id` since Day 8 for the same reason.
  * `stg_company_id` and `stg_company_contact` has zero row with ID = 123.
* Day 15
  * Email updated to beyond@mockdata.com.
  * `stg_company_id` has zero row with ID = 123.
  * `stg_company_contact` has one row with ID = 123.

Despite the changing number of rows with `ID = 123`, the daily ETL should always returns a company with `ID = 123` in its output, the dimension table `dim_company`, with the `email_address` column updated accordingly.

### Initial functionality tests

Initially, verifying incremental data update of ETLs is very challenging.
We approach testing incremental data update just like funcional tests: load the data mart with production-like data, and run multiple ETL runs to simulate multiple days.
Specifically, we collected a few sets of staging tables for three days, and then manually simulate each set as the current day data before running the ETL.
After running the ETL, we will run the corresponding set of automated functional tests for that day, one set for each day.

That process is summarized as the following steps for each day:

1. Manually set up the staging data (ETL input).
1. Manually run the ETL.
1. Run the corresponding set of automated functional tests.

As you can see, even though running the tests is automated, the setup and running ETL is pretty much manual.
It is time consuming to manually set up and run ETLs: for production-like data, the first few days can contain millions of rows for historical data.
Since we run ETLs multiple times to properly verify incremental update, the running times add up.
Besides being time-consuming, the process also takes lots of mental energy to do each of the steps right, in the correct order.
Otherwise, the tests will fail for no apparent reason.

Despite the effort involved, the return is very little.
Most of the time, the difference in data between a few days or weeks are usually not enough to verify all corner cases in ETL scripts.
After running tests, we still don't know if a particular ETL will ever break if some infrequently updated column is updated in some particular way.

### Observations

The painful experience of testing incremental data update for ETLs with production-like data leads to the following observations:

1. We should only need a small number of records to reduce ETL running time.
1. We should create synthetic data to force rare logic branches and corner cases.
1. We should have a way to set up data automatically.
1. We should have a way to run the ETL under test automatically.

These observations, especially small and synthetic data, sounds like unit testing. 
It leads to my strong conviction that incremental data update should tested in a bunch of "unit tests", with mock data to force corner cases.

### Unit tests - first look

I made two changes in the SQL Test Runner to make it easier to do unit testing SQL scripts in Vertica:

1. Add ability to run the SQL statements to set up data.
1. Add ability to call `vsql` to run a list of specified ETLs.

With that, a unit test to verify our ETL (e.g., `my_etl.sql`) that updates email address incrementally (in the example scenario above) will look like this:

``` sql Unit test for the example scenario in section above
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

/**********************************************************
Day 3: Email updated in stg_company_contact
**********************************************************/

INSERT INTO stg_company_contact (company_id,master_email,last_modify_date) 
VALUES (123,'after@mockdata.com',current_timestamp-12);


/* @Test
-- Day 3 ETL run
{
	"name" : "Day3_etl_run",
	"vsql_file" : ["repo_home/sql/my_etl.sql"]
}
*/

/* @Test
{
	"name" : "Day3_check_count",
	"query" : "select count(*) from dim_company",
	"expected" : "1"
}
*/

/* @Test
{
	"name" : "Day3_check_email_address",
	"query" : "select email_address from dim_company",
	"expected" : "after@mockdata.com"
}
*/

/**********************************************************
Day 10: Data truncated from staging table
**********************************************************/

TRUNCATE TABLE stg_company_id;
TRUNCATE TABLE stg_company_contact;

/* @Test
-- This ETL run should have no effect
{
	"name" : "Day10_etl_run",
	"vsql_file" : ["repo_home/sql/my_etl.sql"]
}
*/

/* @Test
{
	"name" : "Day10_check_count",
	"query" : "select count(*) from dim_company",
	"expected" : "1"
}
*/

/* @Test
{
	"name" : "Day10_check_email_address",
	"query" : "select email_address from dim_company",
	"expected" : "after@mockdata.com"
}
*/

/**********************************************************
Day 15: Another update in email
**********************************************************/

-- Email is updated
INSERT INTO stg_company_contact (company_id,master_email,last_modify_date) 
VALUES (123,'beyond@mockdata.com',current_timestamp-3);


/* @Test
-- Day 15 ETL run
{
	"name" : "Day15_etl_run",
	"vsql_file" : ["repo_home/sql/my_etl.sql"]
}
*/

/* @Test
{
	"name" : "Day15_check_count",
	"query" : "select count(*) from dim_company",
	"expected" : "1"
}
*/

/* @Test
{
	"name" : "Day15_check_email_address",
	"query" : "select email_address from dim_company",
	"expected" : "beyond@mockdata.com"
}
*/
```

Running the unit test script above from TestNG will be similar as in functional tests (see "Level 3" in [this post](/blog/2016/03/16/sql-unit-functional-tests/)).
After one-time setup (in `@BeforeClass` and `@AfterClass` functions), there will be minimal Java code added (`@Test` functions):

``` java Calling unit test script
@BeforeClass
public void setup() {
    testRunner = new SqlTestRunner(getJdbcConnection());
}

@Test(enabled = true)
public void validate_dim_region() throws Exception {
        testRunner.runScript("unittests/etl_incremental_update_email.test");
}
```

The full setup for unit testing will be discussed in the next blog post.

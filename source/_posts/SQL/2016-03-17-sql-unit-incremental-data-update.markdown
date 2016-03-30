---
layout: post
title: "Testing Incremental data update"
date: 2016-04-10 17:46:40 -0700
comments: true
published: true
categories: 
- SQL
- Testing
- Automation
---

One of challenges in SQL testing is "incremental data update" in ETL scripts.
Challenges in functional testing motivates me to create a test framework to add unit-like tests for those ETL scripts.

### Incremental data update

In the last [blog post](/blog/2016/03/16/sql-unit-functional-tests/), I go over evolution of functional testing in data mart projects.
In functional tests, we deploy the data marts, run all the DDL, DML and ETL scripts, and, then, execute a bunch of SQL test queries to verify.

That kind of testing is sufficient if the input of the ETL is snapshot tables: data extracted by the ETL scripts are the latest snapshot of the data.
Preparing this snapshot might be expensive, especially for daily ETLs, since those tables have to be truncated and reloaded with latest data.
This can be every inefficient since out of millions of records for twenty years of historical data, less than one percent of those will be updated over a day interval.
Therefore, for performance reasons, the ETLs usually perform **incremental data update**. 
Some characteristics of "incremental data update" are as follows:

1) Only updated records are incrementally appended into some tables, used for staging purpose (a.k.a. staging tables). 
These tables will be used as input for the ETLs.
For example, let's say there is a company record with ID = 123 and some attribute such as master email `before@mock.com` on Day 1.
On Day 2, the company email could be udpated to `after@mock.com`. 
The original record of company 123 with `before@mock.com` is not necessarily removed from the staging table.
Instead, a new row with updated data (ID = 123, email = `after@mock.com`) is appended into the staging table.

2) To keep the size of input tables and ETL running time bounded, we usually keep only a number of days worth of data in the staging tables.
In other words, any records older than some `D` days are truncated from those staging tables.
For example, after `D = 7` days since Day 2, if the company `ID = 123` has no update, its records will be removed from the staging tables.
Note that, after being truncated, that company `ID = 123` can be re-inserted into the staging table if some of its attribute is updated. 

**Risks**: The ETLs with incremental data update is usually much more complex.
Obviously, one risk of running ETL with incremental data update is duplicate records: we could have multiple rows for the same company `ID = 123`. 
In standard approach with snapshot, each record is almost guaranteed unique, meaning only one row with company `ID = 123`.
On the other hand, when data for company `ID = 123` are truncated from the staging tables after `D` days (0 row), it simply means that there is no update to that company during the last `D` days.
It means that the company should not be removed from the destination tables of the ETL even though the input staging tables contain no such row for `ID = 123`.
The following example scenario illustrates the challenge and complexity of ETLs with incremental data update.

### Example scenario

For sliding window of one week data `D = 7` in the staging table `staging_company`, the company with `ID = 123` may have its address updated like this:

* Day 1
  * staging_company -> ID: 123, region: US, email: before@mockdata.com.
* Day 3
  * Email updated to after@mockdata.com.
  * staging_company has two rows with ID = 123.
* Day 10
  * Data truncated from staging_company
  * staging_company has zero row with ID = 123.
* Day 15
  * Email updated to beyond@mockdata.com
  * staging_company has one row with ID = 123.

Despite the changing number of rows with `ID = 123`, the daily ETL should always returns a company with `ID = 123` in some dimension table, with its email updated.

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
It is time consuming to manually set up and run ETLs: for production-like data, the first few days can contain million rows for a whole history of data.
Since we run ETLs multiple times to properly verify incremental update, the running times add up.
Besides time, it also takes lots of mental energy to do each of the step right and in the correct order.
Otherwise, the tests will fail for no apparent reason.
Despite the effort involved, the return is very little.
Most of the time, the difference in data between two dates are usually not enough to verify all corner cases in ETL scripts.
After running it, you still don't know if a particular ETL will ever break if some field is updated in some odd way in an infrequently updated column.

### Observations

The painful experience of testing incremental data update for ETLs leads to the following observations:

1. We should only need a small number of records to reduce ETL running time.
1. We should create synthetic data to force rare logic branches and corner cases.
1. We should have a way to set up data automatically.
1. We should have a way to run the ETL under test automatically.

Guess what? These observations, especially small and synthetic data, sounds like unit testing. 
It leads to my strong conviction that incremental data update should tested in a bunch of "unit tests", with mock data to force corner cases.

### Unit tests - preview

I made two changes in the SQL Test Runner to make it more friendly to do unit testing SQL scripts:

1. Run the SQL statements to set up data.
1. Calling `vsql` to run a list of specified ETLs.

With that, a unit test to verify our ETL (e.g., `company_etl.sql`) that updates email address incrementally (in the example scenario above) will look like this:

``` java Calling unit test script
TODO
```

``` sql Unit test for the example scenario in section above
TODO
```

The setup will be discussed in the next blog post.

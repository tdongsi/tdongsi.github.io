---
layout: post
title: "Testing Incremental data update"
date: 2016-03-17 17:46:40 -0700
comments: true
published: true
categories: 
- SQL
- Testing
- Automation
---

### Incremental data update

I go over evolution of Data Mart functional testing in the last blog post (TODO: link).
In functional tests, we deploy the data marts, run the ETL, and run a bunch of SQL test queries to verify.
That kind of testing is sufficient if the input of the ETL is snapshot tables: data extracted by the ETL are the latest snapshot of the data.
Preparing this snapshot might be expensive, especially for daily ETLs, since those tables have to be truncated and reloaded with latest data.
This can be every inefficient since out of millions of records, maybe less than one percent of those will be updated over a day interval.

Therefore, for performance reasons, sometimes the ETLs perform incremental data update: 
only updated records are appended into some staging tables, used as input for those daily ETLs.
For example, let's say there is a company record with ID = 123 and some attribute such as company email `before@mock.com` on Day 1.
On Day 2, the company email is udpated to `after@mock.com`. 
The original record of company 123 with `before@mock.com` is not necessarily removed from staging table.
Instead, a new row with updated data (ID = 123, email = `after@mock.com`) is appended into the stagingt able.

Obviously, one risk of running ETL with incremental data update is duplicate records: we now have two rows for the same company `ID = 123`. 
In standard approach with snapshot, each record is unique, meaning only one row with company `ID = 123`.

In addition, in our data mart projects, we only keep a sliding window of some days of data in staging tables.
Any records older than D days are truncated from those staging tables.
For example, after `D = 7` days since Day 2, if the company `ID = 123` has no update, its records will be removed from the staging tables.
Note that, after being truncated, that company `ID = 123` can be re-inserted into the staging table if some of its attribute is updated. 

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

### Initial functional tests

Initially, verifying functionality of incremental data update of ETLs is very challenging.
In the initial approach, we collected three sets of staging tables for three days, and then manually simulate each set as the current set before running the ETL.
After running the ETL, we will run the corresponding set of automated functional tests for that day, one set for each day.

That process is summarized as the following steps for each day:

1. Manually set up the staging data (ETL input).
1. Manually run the ETL.
1. Run the corresponding set of automated functional tests.

As you can see, even though running the tests is automated, the setup and running ETL is pretty much manual.
It is time consuming to manually set up and run ETLs: about 4 hours for a proper sequence.
Besides time, it also takes lots of mental energy to do each of the step right and in order.
Otherwise, the tests will fail for no apparent reason.
Despite the effort involved, the return is very little.
Most of the time, the difference in data between two dates are usually not enough to check all corner cases in ETL.
After running it, you still don't know if a particular ETL will ever break if data is updated in some odd way in an infrequently updated column.

### Observations

The painful experience of testing incremental data update for ETLs leads to the following observations:

1. We should only need a small number of records to reduce ETL running time.
1. We should create synthetic data to force rare logic branches and corner cases.
1. We should have a way to set up data automatically.
1. We should have a way to run the ETL under test automatically.

Guess what? These points, especially small and synthetica data, leads to the argument that incremental data update should tested in unit tests, not in functional tests.

### Changes to SQL Test Runner

I made two changes in the SQL Test Runner to make it more friendly to do unit testing SQL scripts:

1. Run the SQL statements to set up data.
1. Calling `vsql` to run a list of specified ETLs.

With that, a unit test to verify our ETL (e.g., `company_etl.sql`) that updates email address incrementally (in the example scenario above) will look like this:

``` java Calling unit test script
TODO
```

``` sql Unit test for the example scenario
TODO
```

TODO: The setup: an empty schema, or even better, a local VM.

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

### Initial approach

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

### Observations

1. I only need a small number of records.
1. I can create synthetic data to force rare logic branches and corner cases.
1. Automatic setup.
1. Automatic running ETL under test.

Guess what? This is exactly unit testing.

### Changes to SQL Test Runner

Two changes

1. Run the SQL scripts to set up data
1. vsql

What unit test looks like.


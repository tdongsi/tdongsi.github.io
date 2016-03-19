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
In functional tests, you deployed the data marts, run the ETL, and run a bunch of SQL queries to verify.
That kind of testing is sufficient if the input of the ETL is snapshots: TODO: how data is update.
However, for performance reasons, sometimes the ETLs perform incremental date update: 
Only updated records is appended.

For example:

One obvious risk is duplicate records: in standard approach, each input table is a snapshot with each record is unique in one row.
In this incremental update approach, some records may have more than one row, and only the latest row is important.

A sliding window. Older records is truncated.

After being truncated, the data can get in.

### Example scenario

Day 1

* stg_rptcompanyids -> region: US
* stg_rptcompanycontactinfo -> email: before@mockdata.com

Day 3

* Email updated to after@mockdata.com

Day 10

* Data truncated from input_region and input_contactinfo

Day 15

* Email updated to beyond@mockdata.com


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


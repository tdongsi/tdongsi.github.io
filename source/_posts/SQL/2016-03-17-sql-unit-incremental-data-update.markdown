---
layout: post
title: "Incremental data update"
date: 2016-03-17 17:46:40 -0700
comments: true
published: false
categories: 
- SQL
- Testing
- Automation
---

### Incremental data update

What incremental update?

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



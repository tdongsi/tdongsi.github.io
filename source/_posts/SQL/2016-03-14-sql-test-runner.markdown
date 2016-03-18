---
layout: post
title: "Functional testing for Data Marts"
date: 2016-03-16 23:18:33 -0700
comments: true
published: true
categories: 
- Vertica
- Testing
- SQL
- Automation
---

In this blog post, I will go over on different approaches over time that we did to verify if a data mart or data warehouse is implemented correctly, and advantages and disadvantages associated with each approach.

### Level 0: Manual testing

Early on in Big Data projects, there was not much automation.
Big Data projects are much different from typical software projects: most of the code complexity (and bugs) lies in Extract-Transform-Load (ETL) processes, typically implemented as a number of SQL scripts.
There are not many tools available for automated testing of SQL scripts, especially for Vertica.

We, quality engineers and data analysts, tested Data Marts by using a number of SQL queries as test queries.
Data analysts who are *de facto* end-users and main testers provide those test queries based on their experience.

{% img center /images/sql/SQuirreL.png Manual testing %}

We used some SQL clients such as SQuirreL as shown above, connected to Vertica using some JDBC driver, ran the test queries and verified that the outputs match our expectations.
This process is pretty much manual. If an ETL is updated `n` times, we have to repeat this `n` times.
Most of the test queries can only tests the **end results** of ETL processes, where data analysts have domain knowledge on: they know what numbers from those final numbers should look like.
If there are multiple steps (multiple SQL scripts) in those ETL processes, the intermediate tables are not really accessible to data analysts.
Sometimes, some of these tests are pretty arbitrary, such as number of products sold in some channel is "unusually" high, which "seems" to indicate that ETL went wrong in some intermediate step.

<!--
Functions is not common. 
-->

### Level 1: TestNG

Remove arbitrariness, we narrow down to test queriers that have clear cut right or wrong.

Pro:
It is automated. You can run multiple times with minimal effort.

Con:
Java and SQL code are mixed together.
Hard to read, hard to maintain.

### Level 2: Properties files

SQL code is separated. Java code is abstracted into utility.

Pro:
It is easier to go over/maintain SQL test queries.

Con:
Test queries and their assertions (expected ouputs) are not paired. 
Hard to look up and update expected outputs.
All queries have to be in a single line. Hard to read for long test queries. 

TODO: Show WITH statements 

### Level 3: Script files

Pro:
It is automated.
Java and SQL codes are separated.
Assertions/Expected outputs are paired with test queries.
Readable by data analysts.

In one of our Big Data projects, the developers are more comfortable with working in SQL. Not all of them are comfortable with working with Java or other languages (e.g., Python) that can make automated testing feasible.

From QE side, I used Java and TestNG for test automation. I created a small test framework that allows developers to inject SQL tests into their scripts. All test automation (in Java) is abstracted from developers, and they can add tests totally in SQL. The developers are slowly adopting that framework.


Big Data projects different from usual software engineering projects is that users, Data analysts, know more about the data than you.
They are the much better testers than any typical QE engineer, and being to able to get their input is essential in ensuring Big Data projects doing the right thing in the right ways.
Being able to get help from them is good for testing.


Data analysts, the de-facto end-users and testers, usually not familiar with any other languages than SQL.

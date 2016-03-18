---
layout: post
title: "Functional testing for Data Marts"
date: 2016-03-16 23:18:33 -0700
comments: true
published: false
categories: 
- Vertica
- Testing
- SQL
- Automation
---

In this blog post, I will go over on different approaches that we could do to verify if a Data Mart is implemented correctly, and advantages and disadvantages associated with each approach.

### Level 0: Manual testing


### Level 1: TestNG

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
---
layout: post
title: "AWS: Developing with Amazon DynamoDB"
date: 2016-01-13 10:38:29 -0800
comments: true
categories:
- AWS 
- Database
- Java
- Python
---

DynamoDB has partition key and sort key, the latter is optional. 
Primary key is composed of the partition key and the optional sort key that uniquely identifies an item (ie., "row") in the table.

DynamoDB supports both modes of "eventually consistent" and "strongly consistent" reads.

* Eventually consistent read may return slightly stale data if read operation is immediate after a write operation.
* Strongly consistent read returns most up-to-date data.

Streams: analogous to triggers in SQL databases. You can specify streams when creating a table in DynamoDB.

Best practices: http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/BestPractices.html


---
layout: post
title: "Learning Hive (Pt. 1): Introduction"
date: 2015-11-22 17:22:51 -0800
comments: true
categories: 
- Book
- Hadoop
- Hive
- SQL
---

<!---
"Chapter 1: Introduction" of the "Programming Hive" book.
-->

This post is the first of many Hive review posts. 
Most of these posts are based on the **Programming Hive** book, with some observations from my own experience with [Cloudera Quickstart VM](/blog/2015/11/20/wordcount-sample-in-cloudera-quickstart-vm/).

{% img center /images/hive/cat.gif Cover %}

<!--more-->

### Introduction

Hive provides a SQL dialect, called Hive Query Language (HiveQL or HQL) for querying data stored in a Hadoop cluster. SQL knowledge is widespread for a reason; it's an effective, reasonably intuitive model for organizing and using data. Therefore, Hive helps lower the barrier, making transition to Hadoop from traditional relational databases easier for database users such as business analysts.

Note that Hive is more suited for data warehouse applications, where data is relatively static and fast response time is not required. For example, a simple query such as `select count(*) from my_table` can take several seconds for a very small table (mostly due to startup overhead for MapReduce jobs). Hive is a heavily batch-oriented system: in addition to large startup overheads, it neither provides record-level update, insert, or delete nor transactions. In short, Hive is not a full database (hint: check HBase).

HiveQL does not conform to the ANSI SQL standard (not many do), but it is quite close to MySQL dialect.

### Hive within the Hadoop Ecosystem

A basic understanding of Hadoop and MapReduce can help you to understand and appreciate how Hive works. Simple examples such as WordCount in my [last post](/blog/2015/11/21/explaining-wordcount-example/) can be very involving when using the Hadoop Java API. The API requires Java developers to manage many low-level details, repetitive wiring to/from Mappers and Reducers. The WordCount example's Java implementation can be found [here](https://wiki.apache.org/hadoop/WordCount). 

Hive not only eliminates advanced, sometimes repetitive Java coding but also provides a familiar interface to those who know SQL. Hive lets you complete a lot of work with relatively little effort. For example, the same WordCount example in HiveQL can be as simple as:

``` sql WordCount example in HiveQL
CREATE TABLE docs (line STRING);

/* Load text files into TABLE docs: each line as a row */
LOAD DATA INPATH 'wordcount.txt' OVERWRITE INTO TABLE docs;

CREATE TABLE word_counts AS
SELECT word, count(1) AS count
FROM
   -- explode will return rows of tokens
  (SELECT explode(split(line, '\s')) AS word
   FROM docs) w
GROUP BY word
ORDER BY word;
```

<!--
In the remaining sections of Chapter 1, the authors also discuss various related Hadoop projects such as Pig, Hue, HBase, Spark, Storm, Kafka, etc.
-->

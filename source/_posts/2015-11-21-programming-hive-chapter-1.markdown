---
layout: post
title: "Programming Hive: Introduction"
date: 2015-11-21 17:22:51 -0800
comments: true
categories: 
- Book
- Hadoop
- Hive
- SQL
---

This is my summary for Chapter 1 of "Programming Hive" book.

<!--more-->

### Introduction

Hive provides a SQL dialect, called Hive Query Language (HiveQL or HQL) for querying data stored in a Hadoop cluster. SQL knowledge is widespread for a reason; it's an effective, reasonably intuitive model for organizing and using data. Therefore, Hive helps lower the barrier, making transition to Hadoop from traditional relational databases easier for expert data designers and administrators.

Note that Hive is suited for data warehouse applications, where data is relatively static and fast response time is not required. For example, a simple query such as `select count(*) from my_table` can take several seconds for a very small table (mostly due to startup overhead for MapReduce jobs). Hive is a heavily batch-oriented system: in addition to large startup overheads, it neither provides record-level update, insert, or delete nor transactions. In short, Hive is not a full database.

HiveQL does not conform to the ANSI SQL standard (which is usual), with MySQL dialect being the closest.

### Overview of Hadoop and MapReduce

MapReduce is a programming framework that decomposes large data processing jobs into individual tasks that can be executed in parallel across a cluster of servers. The term MapReduce comes from the fact that there are two fundamental data transformation operations: *map* and *reduce*.

TODO: Linked to the last blog.

TODO: MapReduce in WordCount example.

“ A map operation converts the elements of a collection from one form to another. In this case, input key-value pairs are converted to zero-to-many output key-value pairs, where the input and output keys might be completely different and the input and output values might be completely different.

In MapReduce, all the key-pairs for a given key are sent to the same reduce operation. Specifically, the key and a collection of the values are passed to the reducer. The goal of “reduction” is to convert the collection to a value, such as summing or averaging a collection of numbers, or to another collection. A final key-value pair is emitted by the reducer. Again, the input versus output keys and values may be different. Note that if the job requires no reduction step, then it can be skipped.”


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

This is my summary for "Chapter 1: Introduction" of the "Programming Hive" book, with some observations from my hands-on experience.

### Introduction

Hive provides a SQL dialect, called Hive Query Language (HiveQL or HQL) for querying data stored in a Hadoop cluster. SQL knowledge is widespread for a reason; it's an effective, reasonably intuitive model for organizing and using data. Therefore, Hive helps lower the barrier, making transition to Hadoop from traditional relational databases easier for expert database designers and administrators.

Note that Hive is more suited for data warehouse applications, where data is relatively static and fast response time is not required. For example, a simple query such as `select count(*) from my_table` can take several seconds for a very small table (mostly due to startup overhead for MapReduce jobs). Hive is a heavily batch-oriented system: in addition to large startup overheads, it neither provides record-level update, insert, or delete nor transactions. In short, Hive is not a full database.

HiveQL does not conform to the ANSI SQL standard (which is usual), with MySQL dialect being the closest.

### Overview of Hadoop and MapReduce

A basic understanding of Hadoop and MapReduce can help you to understand how Hive works. MapReduce is a programming framework that decomposes large data processing jobs into individual tasks that can be executed in parallel across a cluster of servers. The name MapReduce comes from the fact that there are two fundamental data transformation operations: *map* and *reduce*. These MapReduce operations would be more clear if we walk through a simple example, such as WordCount in my last [post](/blog/2015/11/20/wordcount-sample-in-cloudera-quickstart-vm/).

A *map* operation converts the elements of a collection from one form to another. In this case, input key-value pairs are converted to zero-to-many output key-value pairs. In WordCount, the character offset (key) is discarded. The value, the line of text, is tokenized into words, using one of several possible techniques (e.g., splitting on whitespace is the simplest, but it can leave in undesirable punctuation). We’ll also assume that the Mapper converts each word to lowercase, so for example, “FUN” and “fun” will be counted as the same word.

“Finally, for each word in the line, the mapper outputs a key-value pair, with the word as the key and the number 1 as the value (i.e., the count of “one occurrence”). Note that the output types of the keys and values are different from the input types.”

Excerpt From: Edward Capriolo, Dean Wampler, and Jason Rutherglen. “Programming Hive.” iBooks. 

“Sort and Shuffle phase that comes next. Hadoop sorts the key-value pairs by key and it “shuffles” all pairs with the same key to the same Reducer. There are several possible techniques that can be used to decide which reducer gets which range of keys.”

Excerpt From: Edward Capriolo, Dean Wampler, and Jason Rutherglen. “Programming Hive.” iBooks. 


In MapReduce, all the key-pairs for a given key are sent to the same reduce operation. Specifically, the key and a collection of the values are passed to the reducer. The goal of “reduction” is to convert the collection to a value, such as summing or averaging a collection of numbers, or to another collection. A final key-value pair is emitted by the reducer. Again, the input versus output keys and values may be different. Note that if the job requires no reduction step, then it can be skipped.”

“The inputs to each Reducer are again key-value pairs, but this time, each key will be one of the words found by the mappers and the value will be a collection of all the counts emitted by all the mappers for that word. Note that the type of the key and the type of the value collection elements are the same as the types used in the Mapper’s output. That is, the key type is a character string and the value collection element type is an integer.
To finish the algorithm, all the reducer has to do is add up all the counts in the value collection and write a final key-value pair consisting of each word and the count for that word.”

Excerpt From: Edward Capriolo, Dean Wampler, and Jason Rutherglen. “Programming Hive.” iBooks. 

### Hive within the Hadoop Ecosystem

Simple examples such as WordCount above can be very involving when using the Hadoop Java API with many low-level details, repetitive wiring to/from Mappers and Reducers have to be taken care of (see [WordCount in Java](https://wiki.apache.org/hadoop/WordCount)). Hive not only eliminates advanced, sometimes repetitive Java coding but also provides a familiar interface to those who know SQL. Hive lets you complete a lot of work with relatively little effort. For example, the same WordCount example in HiveQL is as simple as:

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

In the remaining sections of the chapter, the authors also discuss various related Hadoop projects such as Pig, Hue, HBase, Spark, Storm, Kafka.

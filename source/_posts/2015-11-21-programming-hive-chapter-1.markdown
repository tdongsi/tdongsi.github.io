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

<!---
"Chapter 1: Introduction" of the "Programming Hive" book.
-->

This post is the first of many posts summarizing the "Programming Hive" book, with some observations from my own experience.

### Introduction

Hive provides a SQL dialect, called Hive Query Language (HiveQL or HQL) for querying data stored in a Hadoop cluster. SQL knowledge is widespread for a reason; it's an effective, reasonably intuitive model for organizing and using data. Therefore, Hive helps lower the barrier, making transition to Hadoop from traditional relational databases easier for expert database designers and administrators.

Note that Hive is more suited for data warehouse applications, where data is relatively static and fast response time is not required. For example, a simple query such as `select count(*) from my_table` can take several seconds for a very small table (mostly due to startup overhead for MapReduce jobs). Hive is a heavily batch-oriented system: in addition to large startup overheads, it neither provides record-level update, insert, or delete nor transactions. In short, Hive is not a full database (hint: check HBase).

HiveQL does not conform to the ANSI SQL standard (not many do), but quite close to MySQL dialect.

### Overview of Hadoop and MapReduce: Explaining WordCount Example

A basic understanding of Hadoop and MapReduce can help you to understand how Hive works. MapReduce is a programming framework that decomposes large data processing jobs into individual tasks that can be executed in parallel across a cluster of servers. The name MapReduce comes from the fact that there are two fundamental data transformation operations: *map* and *reduce*. These MapReduce operations would be more clear if we walk through a simple example, such as WordCount in my last [post](/blog/2015/11/20/wordcount-sample-in-cloudera-quickstart-vm/). The process flow of WordCount example is shown below:


![Process Flow of WordCount Example](https://www.safaribooksonline.com/library/view/programming-hive/9781449326944/httpatomoreillycomsourceoreillyimages1321235.png)

The fundamental data structure for input and output in MapReduce is the key-value pair. When starting the WordCount example, the Mapper processes the document line by line, with the key being the character offset into the document and the value being the line of text.

A **map** operation converts input key-values pairs from one form to another. In WordCount, the key (character offset) is discarded but it may not be always the case. The value (the line of text) is normalized (e.g., converted to lower case) and tokenized into words, using some technique such as splitting on whitespace. In this way, “HADOOP” and “Hadoop” will be counted as the same word. For each word in the line, the Mapper outputs a key-value pair, with the word as the key and the number 1 as the value.

Next is the **shuffling** phase. Hadoop sorts the key-value pairs by key and it “shuffles” all pairs with the same key to the same Reducer. In the WordCount example, each Reducer may get some range of keys, i.e. a group of words/tokens.

A **reduce** operation converts the collection for each key in input key-value pairs to another smaller collection or a value, such as summing. In WordCount, the input key is one of the words found and the value will be a collection of all the counts for that word. The Reducers add all the counts in the value collection and the final output are key-value pairs consisting of each word and the count for that word.

The three phases of processing in WordCount example with their input and output key-value pairs are summarized in the table below. Note that the input and output key-value pairs can be very different for each phase, not only in value but also in type.

| | Mapper | Shuffling | Reducer |
| --- | --- | --- | --- |
| **Input** | `(offset, text_line)` | Multiple `(token,1)` | `(token,[1,1,1,...])` |
| **Processing** | Discard the key `offset`. Normalize and tokenize `text_line`.| Move `(token,1)`with same `token` to same Reducer | Sum all elements in collection |
| **Output** | Multiple `(token,1)` | Sorted `(token,[1,1,1,...])` | Multiple (token, count) |

<br>

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

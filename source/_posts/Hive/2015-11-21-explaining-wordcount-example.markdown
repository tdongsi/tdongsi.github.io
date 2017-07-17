---
layout: post
title: "Overview of MapReduce: Explaining WordCount Example"
date: 2015-11-21 02:37:20 -0800
comments: true
categories: 
- Book
- Hadoop
- Java
---

MapReduce is a programming framework that decomposes large data processing jobs into individual tasks that can be executed in parallel across a cluster of servers. 
The name MapReduce comes from the fact that there are two fundamental data transformation operations: *map* and *reduce*. 
These MapReduce operations would be more clear if we walk through a simple example, such as WordCount in my last [post](/blog/2015/11/20/wordcount-sample-in-cloudera-quickstart-vm/). 
The process flow of the WordCount example is shown below: 

<!---
(from [here](https://www.safaribooksonline.com/library/view/programming-hive/9781449326944/ch01.html)):

![Process Flow of WordCount Example](https://www.safaribooksonline.com/library/view/programming-hive/9781449326944/httpatomoreillycomsourceoreillyimages1321235.png)
-->

{% img center /images/hive/wordcount.png Process Flow of WordCount Example %}

<!--more-->

The fundamental data structure for input and output in MapReduce is the key-value pair. When starting the WordCount example, the Mapper processes the input documents line by line, with the key being the character offset into the document and the value being the line of text.

A **map** operation converts input key-values pairs from one form to another. In WordCount, the key (character offset) is discarded but it may not be always the case. The value (the line of text) is normalized (e.g., converted to lower case) and tokenized into words, using some technique such as splitting on whitespace. In this way, “HADOOP” and “Hadoop” will be counted as the same word. For each word in the line, the Mapper outputs a key-value pair, with the word as the key and the number 1 as the value.

Next is the **shuffling** phase. Hadoop sorts the key-value pairs by key and it “shuffles” all pairs with the same key to the same Reducer. In the WordCount example, each Reducer may get some range of keys, i.e. a group of words/tokens.

A **reduce** operation converts the collection for each key in input key-value pairs to another smaller collection (or a value when the collection has a single element). In WordCount, the input key is one of the words found and the value will be a collection of all the counts for that word. The Reducers add all the counts in the value collection and the final output are key-value pairs consisting of each word and the count for that word.

The three phases of processing in WordCount example with their input and output key-value pairs are summarized in the table below. Note that the input and output key-value pairs can be very different for each phase, not only in value but also in type.

| | Mapper | Shuffling | Reducer |
| --- | --- | --- | --- |
| **Input** | `(offset, text_line)` | Multiple `(token,1)` | `(token,[1,1,1,...])` |
| **Processing** | Discard the key `offset`. <br> Normalize and tokenize `text_line`.| Move `(token,1)`with same `token` to same Reducer | Sum all elements in collection |
| **Output** | Multiple `(token,1)` | Sorted `(token,[1,1,1,...])` | `(token, count)` |

<br>
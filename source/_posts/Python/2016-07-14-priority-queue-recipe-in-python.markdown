---
layout: post
title: "Improved Priority Queue recipe in Python"
date: 2016-07-14 17:59:14 -0700
comments: true
categories: 
- Python
- Algorithm
---

A priority queue is a common abstract data type, but it is not directly provided in Python's standard library.
The moduel `queue` module provides a `PriorityQueue` class but no peek, remove and tuple form.
The module `heapq` provides an implementation of heap algorithms, specifically array-based binary heap, which is a popular data structure for implementing pq. 
Its doc provides a way on how to add capability into. However, that is 


``` python Improved priority-queue recipe

```


A standard Priority Queue recipe is already provided in Python documentation ().
However, there are a few things missing.

* Not in a class
* Method names simplified to: add, remove, pop.
* No peek
* pop does not return priority associated with it
* Add pretty printing


Example: Skyline solution.

http://www.geeksforgeeks.org/divide-and-conquer-set-7-the-skyline-problem/

Skyline problem statement summary.
As opposed to Merge-Sort-like approach, in this approach, I use a pq to keep track of the highest building
while adding/removing buildings at key points (i.e., start and end of buildings).

``` python Solution to Skyline problem

```


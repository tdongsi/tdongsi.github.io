---
layout: post
title: "Best Friend Forever"
date: 2016-04-18 15:44:57 -0700
comments: true
categories: 
- Algorithm
- Python
- Matplotlib
---

BFF is the name of the [problem C](https://code.google.com/codejam/contest/4304486/dashboard#s=p2) in Google Code Jam 2016, Round 1A. 
The summarized problem statement is as follows:

{% blockquote %}
Every kid in your class has a single best friend forever (BFF).
You want to form the largest possible circle of kids such that each kid in the circle is sitting directly next to their BFF, either to the left or to the right.
Give a line that contains N integers F1, F2, ..., FN, where Fi is the student ID number of the BFF of the kid with student ID i, find the greatest number of kids that can be in the circle.
{% endblockquote %}

I'm never a strong [sports programmer](https://en.wikipedia.org/wiki/Competitive_programming).
So, I'd like to approach to the problem more methodically. 
While the first three example test cases, provided in the problem statement, is straight forward, the last example is not so.
First, I would try to plot out 

TODO: insert image

After looking at the graph, it is immediately apparent to me that it is probably not some dynamic programming problem and I actually need some graph algorithm to solve it.
The key observations from the above graph are:

1. Each cyle in the directed graph is a candidate for solution.
1. If the kids form a cycle with length >= 3, then there is no way to insert another kid into that cycle to form a circle that satifies the requirements. 
1. If the kids form a cycle with length == 2 (called as mutual BFFs in my code), then you can keep chaining kids who are friends of friends to those kids to form a path. You can create a circle from **one or more** such paths.

Based on those observations, the solution is pretty "simple":

1. From the list of friends, construct a directed graph.
1. Find all the simple cycles in the directed graph. 
1. For each cyle found:
   1. If cycle length is greater than 2, it is a candidate. Compare its length and update max_length if needed.
   1. If cycle length is equal to 2.
      1. Find the longest friends of friends chain that is connected to either kid in this cycle.
      1. Find the path length and udpate max_length if needed.

TODO: Correct the algorithm

Constructing the directed graph, and finding cycles in it is done using TODO: Python module, as shown below (together with ). 

TODO: code

I know my solution will be probably not accepted in Code Jam (using external library), and that is fine :D. 
It is not like I can implement Johnson's algorithm for finding cycles within two hours.
This solution (TODO) is just to check my thinking is correct.

Note that one mistake we can make is to treat each "path" as a circle candidate (NOTE: "one ore more" in observation 3).
All the "paths" can be chained together to form a larger cycle.
My first solution is rejected for Small Input dataset.
Using the same plotting code above, plot more test cases in the given data set.
This test case come up:

TODO: insert image

The moral of the story: 
plotting helps. Without looking at the graphs, I would wander into the wrong direction, looking for a DP solution.
In real-world problem solving, you don't need to solve the problem in two hours. Even better, you don't need to re-invent the wheel. It is better to arrive at a solution methodically, especially if the solution is scalable.


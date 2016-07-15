---
layout: post
title: "Improved Priority Queue recipe in Python"
date: 2016-07-14 17:59:14 -0700
comments: true
categories: 
- Python
- Algorithm
---

A priority queue is a commonly used abstract data type, but it is not adequately provided in Python's standard library.

The [module `Queue`](https://docs.python.org/2/library/queue.html) provides a `PriorityQueue` class but that implementation leaves a lot to be desired.
It does not provide standard `peek` or `remove` methods in its public interface, which is sometimes critical.
Additionally, the entry must be in the tuple form `(priority_number, data)` where lower number must be used for higher priority task to be returned first (???).
Finally, this Queue version is reportedly slower because it adds locks and encapsulation designed for multi-threaded environment, which is arguably the intention of that module.

On the other hand, the [module `heapq`](https://docs.python.org/2/library/heapq.html) provides an implementation of binary heap algorithms, which is the most common *data structure* for implementing priority-queue. 
Although the module does not provide any direct implementation of priority-queue, [its documentation](https://docs.python.org/2/library/heapq.html) discusses how to add additional capabilities to a heap-based priority queue and provides a recipe as an example.
That example is still hard to be used directly since it is not encapsulated into a class and the standard `peek` method is noticeably missing.

I ended up implementing a wrapper class for that recipe to make it easier to use.


``` python Improved priority-queue recipe
import heapq
import itertools

class PriorityQueue(object):

    _REMOVED = "<REMOVED>"

    def __init__(self):
        self.heap = []
        self.entries = {}
        self.counter = itertools.count()

    def add(self, task, priority=0):
        """Add a new task or update the priority of an existing task"""
        if task in self.entries:
            self.remove(task)

        count = next(self.counter)
        # weight = -priority since heap is a min-heap
        entry = [-priority, count, task]
        self.entries[task] = entry
        heapq.heappush(self.heap, entry)
        pass

    def remove(self, task):
        """ Mark the given task as REMOVED.

        Do this to avoid breaking heap-invariance of the internal heap.
        """
        entry = self.entries[task]
        entry[-1] = PriorityQueue._REMOVED
        pass

    def pop(self):
        """ Get task with highest priority.

        :return: Priority, Task with highest priority
        """
        while self.heap:
            weight, count, task = heapq.heappop(self.heap)
            if task is not PriorityQueue._REMOVED:
                del self.entries[task]
                return -weight, task
        raise KeyError("The priority queue is empty")

    def peek(self):
        """ Check task with highest priority, without removing.

        :return: Priority, Task with highest priority
        """
        while self.heap:
            weight, count, task = self.heap[0]
            if task is PriorityQueue._REMOVED:
                heapq.heappop(self.heap)
            else:
                return -weight, task

        return None

    def __str__(self):
        temp = [str(e) for e in self.heap if e[-1] is not PriorityQueue._REMOVED]
        return "[%s]" % ", ".join(temp)
```

Comparing to the recipe provided in `heapq` module, a few notes about this implementation:

* Task with **higher** priority goes out first. A simple change will remove lots of confusion (and bugs) associated with min-heap implementations. 
* Methods and supporting data structures are encapsulated into a class. 
* Method names are simplified to `add`, `remove`, `pop` (instead of `add_task`, for example) since priority queues are NOT only used for task scheduling.
* Method `peek` is added.
* Method `pop` and `peek` return the highest-priority task together with its priority number. The task's priority number can be useful sometimes (see Skyline problem below).
* Override `__str__` method for pretty printing.

As an example, the above priority-queue implementation is used to solve [the Skyline problem](http://www.geeksforgeeks.org/divide-and-conquer-set-7-the-skyline-problem/).
The Skyline problem states that: 

{% blockquote %}
You are given a set of n rectangular buildings on a skyline. Find the outline around that set of rectangles, which is the skyline when silhouetted at night.
{% endblockquote %}

{% img center http://d1gjlxt8vb0knt.cloudfront.net//wp-content/uploads/skyline-1024x362.png 800 260 'Example' 'An image of example input and output'%}

One possible approach is to use a priority queue to keep track of the current highest building
while moving from left to right and adding/removing buildings at key points (i.e., start and end of buildings).
Compared to the Merge-Sort-like approach detailed in [this link](http://www.geeksforgeeks.org/divide-and-conquer-set-7-the-skyline-problem/), this approach is much more intuitive in my opinion while having similar runtime complexity $\mathcal{O}(n\log{}n)$.

``` python Solution to Skyline problem
def solve_skyline(mlist):
    """ Solve the Skyline problem.

    :param mlist: list of buildings in format (start, end, height).
    :return: List of end points
    """

    skyline = []
    cur_height = 0
    pq = PriorityQueue()
    events = defaultdict(list)
    START = "start"
    END = "end"

    for idx in range(len(mlist)):
        start, end, height = mlist[idx]
        events[start].append((idx, START))
        events[end].append((idx, END))

    # k_events is the ordered list of x-coordinates where buildings start or end (events)
    k_events = sorted(events.keys())

    # Add and remove buildings into a priority-queue for each event.
    for key in k_events:
        # print skyline
        buildings = events[key]

        for e in buildings:
            idx, label = e
            if label == START:
                pq.add(idx, mlist[idx][2])
            elif label == END:
                pq.remove(idx)

        # after processing all buildings for a x-coordinate "key", check the current highest building
        temp = pq.peek()
        after = 0
        if temp is not None:
            after = temp[0]
        if after != cur_height:
            skyline.append((key, after))
            cur_height = after

    return skyline
```

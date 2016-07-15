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
class PriorityQueue(object):

    REMOVED = "<REMOVED>"

    def __init__(self):
        self.heap = []
        self.entries = {}
        self.counter = itertools.count()

    def add(self, task, priority=0):
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
        entry[-1] = PriorityQueue.REMOVED
        pass

    def pop(self):
        """ Get task with highest priority.

        :return: Priority, Task with highest priority
        """
        while self.heap:
            weight, count, task = heapq.heappop(self.heap)
            if task is not PriorityQueue.REMOVED:
                del self.entries[task]
                return -weight, task
        raise KeyError("The priority queue is empty")

    def peek(self):
        """ Check task with highest priority, without removing.

        :return: Priority, Task with highest priority
        """
        while self.heap:
            weight, count, task = self.heap[0]
            if task is PriorityQueue.REMOVED:
                heapq.heappop(self.heap)
            else:
                return -weight, task

        return None

    def __str__(self):
        temp = [str(e) for e in self.heap if e[-1] is not PriorityQueue.REMOVED]
        return "[%s]" % ", ".join(temp)
```


A standard Priority Queue recipe is already provided in Python documentation ().
However, there are a few things missing.

* Max-heap: task with higher priority goes first, not lower priority
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
        tuple = pq.peek()
        after = 0
        if tuple is not None:
            after = tuple[0]
        if after != cur_height:
            skyline.append((key, after))
            cur_height = after

    return skyline
```


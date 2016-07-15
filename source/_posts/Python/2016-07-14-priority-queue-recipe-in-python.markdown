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
It does not provide standard `peek` or `remove` methods in its public interface, which is critical.
Additionally, the entry must be in the tuple form `(priority_number, data)` where lower number must be used for higher priority (???).
Finally, this Queue version is reportedly slower because it adds locks, encapsulation designed for multi-threaded environment, like other components in that module.

On the other hand, the [module `heapq`](https://docs.python.org/2/library/heapq.html) provides an implementation of heap algorithms, specifically array-based binary heap, which is the most common *data structure* for implementing priority-queue. 
Although the module does not provide any direct implementation of priority-queue, [its documentation](https://docs.python.org/2/library/heapq.html) discusses how to add additional capabilities to a heap-based priority queue and provides a recipe as an example.
That recipe is still hard to be used directly since it is not encapsulated and the standard `peek` method is noticeably missing.

I ended up implementing a wrapper class for the recipe to make it easier to use.


``` python Improved priority-queue recipe
import heapq
import itertools

class PriorityQueue(object):

    REMOVED = "<REMOVED>"

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

A few notes about this implementation, compared to recipe provided in `heapq` module:

* Task with higher priority goes out first. A simple change will remove lots of confusion (and bugs) associated with min-heap implementations. 
* Encapsulated into a class with method names simplified to `add`, `remove`, `pop`.
* Method `peek` is added.
* Method `pop` and `peek` return the highest-priority task together with its priority number. The task's priority number can be useful sometimes (see Skyline problem below).
* Override `__str__` method for pretty printing.


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


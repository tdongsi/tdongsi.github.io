---
layout: post
title: "Process Synchronization Concepts in Java (Pt. 1): Producer-Consumer problem"
date: 2015-11-19 14:57:21 -0800
comments: true
published: false
categories: 
- Java
- Concurrency
---

{% include_code java/Concurrency/src/Counter.java %}

{% include_code java/Concurrency/src/Producer.java %}

{% include_code java/Concurrency/src/Consumer.java %}



``` java Producer-Consumer simulation (one producer, one consumer)
	/**
	 * Run the simulation of producer-consumer problem
	 * with the given queue.
	 * 
	 * At the end of simulation run, the queue should have 0 item.
	 */
	public static void produceAndConsume(Counter queue, Producer producer, Consumer consumer) {
		
		Thread t1 = new Thread((Runnable) producer);
		Thread t2 = new Thread((Runnable) consumer);
		
		t1.start();
		t2.start();
		
		try {
			t1.join();
			t2.join();
		} catch (InterruptedException e) {
			// Nothing
      return;
		}
		
	}
```
Once you have concrete implementations of your queue (implementing Counter interface), producer (Producer interface), and consumer (Consumer interface), you can run the simulation easily. One example is as follows:

``` java Run Producer-Consumer with concrete implementations
	public static void main(String[] args) {
		
		Counter queue = new SimpleCounter();
		Producer producer = new SimpleProducer(queue);
		Consumer consumer = new SimpleConsumer(queue);
		produceAndConsume(queue, producer, consumer);
		System.out.println("Queue at the end: " + queue.current());
	}
```


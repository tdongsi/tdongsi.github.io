---
layout: post
title: "WordCount Example in Cloudera Quickstart VM"
date: 2015-11-20 11:47:51 -0800
comments: true
categories: 
- Hadoop
- Java
---

[WordCount](https://wiki.apache.org/hadoop/WordCount) is the Hadoop equivalent of “Hello World” example program. 
When you first start learning a new language or framework, you would want to run and look into some "Hello World" example to get a feel of the new development environment. 
Your first few programs in those new languages or frameworks are probably extended from those basic "Hello World" examples.

Most Hadoop tutorials are quite overwhelming in text, but provide little guide on practical hands-on experiments (such as [this](https://developer.yahoo.com/hadoop/tutorial/)). 
Although they are good and thorough tutorials, many new Hadoop users may be lost midway after walls of texts.

The purpose of this post is to help new users dive into Hadoop more easily. 
After reading this, you should be able to:

1. Get started with a simple, local Hadoop sandbox for hands-on experiments.
1. Perform some simple tasks in HDFS.
1. Run the most basic example program WordCount, using your own input data.

<!--more-->

### Get your Hadoop sandbox

Nowadays, many companies provide Hadoop sandboxes for learning purpose, such as Cloudera, [Hortonworks](http://hortonworks.com/products/hortonworks-sandbox/). In this post, I used [Cloudera Quickstart VM](http://www.cloudera.com/content/www/en-us/documentation/enterprise/5-2-x/topics/cloudera_quickstart_vm.html). Download the VM and start it up in VirtualBox or VMWare Fusion.

### Working with HDFS

Before running WordCount example, we need to create some input text file, then move it to HDFS. First, create an input test file in your local file system.

``` 
[cloudera@quickstart temp]$ echo “This is a hadoop tutorial test" > wordcount.txt
```

Next, we need to move this file into HDFS. The following commands are the most basic HDFS commands to manage files in HDFS. In order of appearance below, we create a folder, copy the input file from local filesystem to HDFS, and list the content on HDFS.

``` 
[cloudera@quickstart temp]$ hdfs dfs -mkdir /user/cloudera/input
[cloudera@quickstart temp]$ hdfs dfs -put /home/cloudera/temp/wordcount.txt /user/cloudera/input
[cloudera@quickstart temp]$ hdfs dfs -ls /user/cloudera/input
Found 1 items
-rw-r--r--   1 cloudera cloudera         31 2015-01-15 18:04 /user/cloudera/input/wordcount.txt
```

It should be noted that for a fresh Cloudera VM, there is a "/user" folder in HDFS but not in the local filesystem. This example illustrates that local file system and HDFS are separate, and the Linux's "ls" and HDFS's "ls" interact with those independently.

``` 
[cloudera@quickstart temp]$ ls /user

ls: cannot access /user: No such file or directory
[cloudera@quickstart temp]$ hdfs dfs -ls /user
Found 5 items
drwxr-xr-x   - cloudera cloudera          0 2014-12-18 07:08 /user/cloudera
drwxr-xr-x   - mapred   hadoop            0 2014-12-18 07:08 /user/history
drwxrwxrwx   - hive     hive              0 2014-12-18 07:08 /user/hive
drwxrwxrwx   - oozie    oozie             0 2014-12-18 07:09 /user/oozie
drwxr-xr-x   - spark    spark             0 2014-12-18 07:09 /user/spark
```
To see the content of a file on HDFS, use cat subcommand:

```
[cloudera@quickstart temp]$ hdfs dfs -cat /user/cloudera/input/wordcount.txt
this is a hadoop tutorial test
```

For large files, if you want to view just the first or last parts, there is no -more or -tail subcommand. Instead, pipe the output of the -cat subcommand through your local shell’s more, or tail. For example: `hdfs dfs -cat wc-out/* | more`.

For more HDFS commands, check out links in References section below.

### Running the WordCount example

Next, we want to run some MapReduce example, such as WordCount. The WordCount example is commonly used to illustrate how MapReduce works. The example returns a list of all the words that appear in a text file and the count of how many times each word appears. The output should show each word found and its count, line by line.

We need to locate the example programs on the sandbox VM. On Cloudera Quickstart VM, they are packaged in this jar file "hadoop-mapreduce-examples.jar". Running that jar file without any argument will give you a list of available examples.

``` 
[cloudera@quickstart temp]$ ls -ltr /usr/lib/hadoop-mapreduce/
lrwxrwxrwx 1 root root      44 Dec 18 07:01 hadoop-mapreduce-examples.jar -> hadoop-mapreduce-examples-2.5.0-cdh5.3.0.jar

[cloudera@quickstart temp]$ hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar
Valid program names are:
  aggregatewordcount: An Aggregate based map/reduce program that counts the words in the input files.
  aggregatewordhist: An Aggregate based map/reduce program that computes the histogram of the words in the input files.
  bbp: A map/reduce program that uses Bailey-Borwein-Plouffe to compute exact digits of Pi.
  dbcount: An example job that count the pageview counts from a database.
  distbbp: A map/reduce program that uses a BBP-type formula to compute exact bits of Pi.
  grep: A map/reduce program that counts the matches of a regex in the input.
  join: A job that effects a join over sorted, equally partitioned datasets
  multifilewc: A job that counts words from several files.
  pentomino: A map/reduce tile laying program to find solutions to pentomino problems.
  pi: A map/reduce program that estimates Pi using a quasi-Monte Carlo method.
  randomtextwriter: A map/reduce program that writes 10GB of random textual data per node.
  randomwriter: A map/reduce program that writes 10GB of random data per node.
  secondarysort: An example defining a secondary sort to the reduce.
  sort: A map/reduce program that sorts the data written by the random writer.
  sudoku: A sudoku solver.
  teragen: Generate data for the terasort
  terasort: Run the terasort
  teravalidate: Checking results of terasort
  wordcount: A map/reduce program that counts the words in the input files.
  wordmean: A map/reduce program that counts the average length of the words in the input files.
  wordmedian: A map/reduce program that counts the median length of the words in the input files.
  wordstandarddeviation: A map/reduce program that counts the standard deviation of the length of the words in the input files.
```

To run the WordCount example using the input file that we just moved to HDFS, use the following command:

``` 
[cloudera@quickstart temp]$ hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar wordcount 
/user/cloudera/input/wordcount.txt /user/cloudera/output

15/11/15 18:14:45 INFO client.RMProxy: Connecting to ResourceManager at /0.0.0.0:8032
15/11/15 18:14:46 INFO input.FileInputFormat: Total input paths to process : 1
15/11/15 18:14:46 INFO mapreduce.JobSubmitter: number of splits:1
15/11/15 18:14:46 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1421372394109_0001
15/11/15 18:14:46 INFO impl.YarnClientImpl: Submitted application application_1421372394109_0001
15/11/15 18:14:46 INFO mapreduce.Job: The url to track the job: http://quickstart.cloudera:8088/proxy/application_1421372394109_0001/
15/11/15 18:14:46 INFO mapreduce.Job: Running job: job_1421372394109_0001
15/11/15 18:14:55 INFO mapreduce.Job: Job job_1421372394109_0001 running in uber mode : false
15/11/15 18:14:55 INFO mapreduce.Job:  map 0% reduce 0%
15/11/15 18:15:01 INFO mapreduce.Job:  map 100% reduce 0%
15/11/15 18:15:07 INFO mapreduce.Job:  map 100% reduce 100%
15/11/15 18:15:08 INFO mapreduce.Job: Job job_1421372394109_0001 completed successfully
```

The output folder is specified as "/user/cloudera/output" in the above command. Finally, check the output of WordCount example in the output folder.

``` 
[cloudera@quickstart temp]$ hdfs dfs -ls /user/cloudera/output

Found 2 items
-rw-r--r--   1 cloudera cloudera          0 2015-11-15 18:15 /user/cloudera/output/_SUCCESS
-rw-r--r--   1 cloudera cloudera         43 2015-11-15 18:15 /user/cloudera/output/part-r-00000
[cloudera@quickstart temp]$ hdfs dfs -cat /user/cloudera/output/part-r-00000
a     1
hadoop     1
is     1
test     1
this     1
tutorial     1
```

Congratulations!! You just finished the first step of the journey into Hadoop.

### Additional links

1. http://hortonworks.com/hadoop-tutorial/using-commandline-manage-files-hdfs/
1. http://wiki.apache.org/hadoop/WordCount
1. https://developer.yahoo.com/hadoop/tutorial/



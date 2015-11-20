---
layout: post
title: "WordCount Sample in Cloudera Quickstart VM"
date: 2015-11-20 11:47:51 -0800
comments: true
categories: 
---

[WordCount](https://wiki.apache.org/hadoop/WordCount) is the Hadoop equivalent of “Hello World” sample program.

[Cloudera Quickstart VM](http://www.cloudera.com/content/www/en-us/documentation/enterprise/5-2-x/topics/cloudera_quickstart_vm.html)

[cloudera@quickstart temp]$ echo “This is a hadoop tutorial test" > wordcount.txt

[cloudera@quickstart temp]$ ls /user

ls: cannot access /user: No such file or directory
[cloudera@quickstart temp]$ hdfs dfs -ls /user
Found 5 items
drwxr-xr-x   - cloudera cloudera          0 2014-12-18 07:08 /user/cloudera
drwxr-xr-x   - mapred   hadoop            0 2014-12-18 07:08 /user/history
drwxrwxrwx   - hive     hive              0 2014-12-18 07:08 /user/hive
drwxrwxrwx   - oozie    oozie             0 2014-12-18 07:09 /user/oozie
drwxr-xr-x   - spark    spark             0 2014-12-18 07:09 /user/spark

[cloudera@quickstart temp]$ hdfs dfs -mkdir /user/cloudera/input
[cloudera@quickstart temp]$
[cloudera@quickstart temp]$ hdfs dfs -put /home/cloudera/temp/wordcount.txt /user/cloudera/input
[cloudera@quickstart temp]$
[cloudera@quickstart temp]$ hdfs dfs -ls /user/cloudera/input
Found 1 items
-rw-r--r--   1 cloudera cloudera         31 2015-01-15 18:04 /user/cloudera/input/wordcount.txt

Locate the samples
[cloudera@quickstart temp]$ ls -ltr /usr/lib/hadoop-mapreduce/
lrwxrwxrwx 1 root root      44 Dec 18 07:01 hadoop-mapreduce-examples.jar -> hadoop-mapreduce-examples-2.5.0-cdh5.3.0.jar

[cloudera@quickstart temp]$ hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar
List of examples

[cloudera@quickstart temp]$ hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar wordcount /user/cloudera/input/wordcount.txt /user/cloudera/output
15/01/15 18:14:45 INFO client.RMProxy: Connecting to ResourceManager at /0.0.0.0:8032
15/01/15 18:14:46 INFO input.FileInputFormat: Total input paths to process : 1
15/01/15 18:14:46 INFO mapreduce.JobSubmitter: number of splits:1
15/01/15 18:14:46 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1421372394109_0001
15/01/15 18:14:46 INFO impl.YarnClientImpl: Submitted application application_1421372394109_0001
15/01/15 18:14:46 INFO mapreduce.Job: The url to track the job: http://quickstart.cloudera:8088/proxy/application_1421372394109_0001/
15/01/15 18:14:46 INFO mapreduce.Job: Running job: job_1421372394109_0001
15/01/15 18:14:55 INFO mapreduce.Job: Job job_1421372394109_0001 running in uber mode : false
15/01/15 18:14:55 INFO mapreduce.Job:  map 0% reduce 0%
15/01/15 18:15:01 INFO mapreduce.Job:  map 100% reduce 0%
15/01/15 18:15:07 INFO mapreduce.Job:  map 100% reduce 100%
15/01/15 18:15:08 INFO mapreduce.Job: Job job_1421372394109_0001 completed successfully

[cloudera@quickstart temp]$ hdfs dfs -ls /user/cloudera/output

Found 2 items
-rw-r--r--   1 cloudera cloudera          0 2015-01-15 18:15 /user/cloudera/output/_SUCCESS
-rw-r--r--   1 cloudera cloudera         43 2015-01-15 18:15 /user/cloudera/output/part-r-00000
[cloudera@quickstart temp]$ hdfs dfs -cat /user/cloudera/output/part-r-00000
a     1
hadoop     1
is     1
test     1
this     1
tutorial     1


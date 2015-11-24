---
layout: post
title: "Programming Hive (Pt. 3): Getting Started"
date: 2015-11-24 18:24:30 -0800
comments: true
categories: 
- Book
- Hadoop
- Hive
---

Chapter 2 of the **Programming Hive** book mostly discusses how to install Hadoop and Hive on Linux and Mac OS X, and how to run WordCount example (see my last [post](/blog/2015/11/20/wordcount-sample-in-cloudera-quickstart-vm/)) to make sure everything works.

### Runtime modes

Local mode, distributed mode.

“the default mode is local mode, where filesystem references use the local filesystem. Also in local mode, when Hadoop jobs are executed (including most Hive queries), the Map and Reduce tasks are run as part of the same process.”
“Actual clusters are configured in distributed mode, where all filesystem references that aren’t full URIs default to the distributed filesystem (usually HDFS) and jobs are managed by the JobTracker service, with individual tasks executed in separate processes.”
“a single machine can be configured to run in pseudodistributed mode, where the behavior is identical to distributed mode, namely filesystem references default to the distributed filesystem and jobs are managed by the JobTracker service, but there is just a single machine.”

#### Local Mode Configuration

Check section

#### Distributed and Pseudodistributed Mode Configuration

#### Metastore Using JDBC

“Hive requires only one extra component that Hadoop does not already have; the metastore component. The metastore stores metadata such as table schema and partition information that you specify when you run commands such as create table x..., or alter table y..., etc.”

Excerpt From: Edward Capriolo, Dean Wampler, and Jason Rutherglen. “Programming Hive.” iBooks. 

“Any JDBC-compliant database can be used for the metastore. In practice, most installations of Hive use MySQL.”

Excerpt From: Edward Capriolo, Dean Wampler, and Jason Rutherglen. “Programming Hive.” iBooks. 

“The information required for table schema, partition information, etc., is small, typically much smaller than the large quantity of data stored in Hive. As a result, you typically don’t need a powerful dedicated database server for the metastore. However because it represents a Single Point of Failure (SPOF), it is strongly recommended that you replicate and back up this database using the standard techniques you would normally use with other relational database instances.”

Excerpt From: Edward Capriolo, Dean Wampler, and Jason Rutherglen. “Programming Hive.” iBooks. 


 



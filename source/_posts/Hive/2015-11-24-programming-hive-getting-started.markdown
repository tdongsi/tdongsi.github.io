---
layout: post
title: "Learning Hive (Pt. 3): Runtime Modes"
date: 2015-11-24 18:24:30 -0800
comments: true
published: true
categories: 
- Book
- Hadoop
- Hive
- JDBC
---

Following up on [Hive CLI](/blog/2015/11/23/programming-hive-hive-cli/), this post covers some lower-level details of Hive such as Hadoop runtime modes and metastore.

<!--more-->

### Runtime Modes

There are different runtime modes for Hadoop. 
Because Hive uses Hadoop jobs for most of its work, its behavior is dependent on Hadoop runtime mode that you are using. 
However, even in distributed mode, Hive can decide on a per-query basis if it can perform the query using just local mode to provide better turnaround.

| Local Mode | Distributed Mode | Pseudodistributed Mode |
| --- | --- | --- |
| Filesystem references use local filesystem. | Filesystem references use HDFS. | Similar to distributed mode. |
| MapReduce tasks in same process. |  MapReduce tasks in separate <br>processes, managed by JobTracker service. | Similar to distributed mode.|
| Default mode. | Usually configured for server clusters. | Like a cluster of one node.|

<br>

Pseudodistributed mode is mainly for developers working on personal machines or VM's when testing their applications since local mode doesn’t fully reflect the behavior of a real cluster. Changes to configuration are done by editing the `hive-site.xml` file in `$HIVE_HOME/conf` folder (e.g., `/usr/lib/hive/conf` on Cloudera VM). Create one if it doesn’t already exist.

### Metastore Using JDBC

Hive requires only one extra component that Hadoop does not already have; the metastore component. 
The metastore stores metadata such as table schema and partition information that you specify when you run commands such as `create table x...`, or `alter table y...`, etc. 
Any JDBC-compliant database can be used for the metastore. In practice, most installations of Hive use MySQL. 
In `hive-site.xml` file, the metastore database configuration looks like this:

``` xml
  <property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:mysql://127.0.0.1/metastore?createDatabaseIfNotExist=true</value>
    <description>JDBC connect string for a JDBC metastore</description>
  </property>

  <property>
    <name>javax.jdo.option.ConnectionDriverName</name>
    <value>com.mysql.jdbc.Driver</value>
    <description>Driver class name for a JDBC metastore</description>
  </property>

  <property>
    <name>javax.jdo.option.ConnectionUserName</name>
    <value>hive</value>
  </property>
```

The information stored in metastore is typically much smaller than the data stored in Hive. 
Therefore, you typically don’t need a powerful dedicated database server for the metastore. 
However since it represents a Single Point of Failure (SPOF), it is strongly recommended that you replicate and back up this database using the best practices like any other database instances.


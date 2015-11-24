---
layout: post
title: "Programming Hive (Pt. 2): Hive CLI"
date: 2015-11-23 19:47:23 -0800
comments: true
categories: 
- Book
- Hadoop
- Hive
- Cloudera
---

{% img center /images/hive/cat.gif Cover %}

Chapter 2 of the book covers how to get started with Hive and cover some basics of Hive and its command-line interface (CLI).

### Starting Hive with Cloundera Quickstart VM

On Cloudera Quickstart VM, the cores of its Hive distribution, including files such as `hive-exec*.jar` and `hive-metastore*.jar`, can be found in `/usr/lib/hive/lib`. The Hive executables can be found in `/usr/lib/hive/bin`.
 
```
[cloudera@quickstart temp]$ hive

Logging initialized using configuration in file:/etc/hive/conf.dist/hive-log4j.properties
hive> CREATE TABLE x (a INT);
OK
Time taken: 3.032 seconds
hive> SELECT * FROM x;
OK
Time taken: 0.465 seconds
hive> SELECT *        
    > FROM x;
OK
Time taken: 0.049 seconds
hive> DROP TABLE x;
OK
Time taken: 0.348 seconds
hive> exit;
```

### Hive services

The `hive` shell command is the wrapper to multiple Hive services, including the CLI.

```
[cloudera@quickstart temp]$ hive --help
Usage ./hive <parameters> --service serviceName <service parameters>
Service List: beeline cli help hiveserver2 hiveserver hwi jar lineage metastore metatool orcfiledump rcfilecat schemaTool version 
Parameters parsed:
  --auxpath : Auxillary jars 
  --config : Hive configuration directory
  --service : Starts specific service/component. cli is default
Parameters used:
  HADOOP_HOME or HADOOP_PREFIX : Hadoop install directory
  HIVE_OPT : Hive options
For help on a particular service:
  ./hive --service serviceName --help
Debug help:  ./hive --debug --help
```

Note the list of services following the line "Service List". There are several services available, most notably **cli, hwi, jar, metastore**. You can use `--service name` option to invoke a service. CLI is the default service, not specifying any service in `hive` command will run CLI service, as shown above.

TODO: Try out HWI

https://cwiki.apache.org/confluence/display/Hive/HiveWebInterface

### Hive CLI

This shows available options for Hive CLI:

```
[cloudera@quickstart temp]$ hive --help --service cli
usage: hive
 -d,--define <key=value>          Variable subsitution to apply to hive
                                  commands. e.g. -d A=B or --define A=B
    --database <databasename>     Specify the database to use
 -e <quoted-query-string>         SQL from command line
 -f <filename>                    SQL from files
 -H,--help                        Print help information
 -h <hostname>                    connecting to Hive Server on remote host
    --hiveconf <property=value>   Use value for given property
    --hivevar <key=value>         Variable subsitution to apply to hive
                                  commands. e.g. --hivevar A=B
 -i <filename>                    Initialization SQL file
 -p <port>                        connecting to Hive Server on port number
 -S,--silent                      Silent mode in interactive shell
 -v,--verbose                     Verbose mode (echo executed SQL to the
                                  console)
```
#### Hive variables and properties

“The --define key=value option is effectively equivalent to the --hivevar key=value option. Both let you define on the command line custom variables that you can reference in Hive scripts to customize execution.”

Excerpt From: Edward Capriolo, Dean Wampler, and Jason Rutherglen. “Programming Hive.” iBooks. 

“When you use this feature, Hive puts the key-value pair in the hivevar “namespace” to distinguish these definitions from three other built-in namespaces, hiveconf, system, and env.”

Excerpt From: Edward Capriolo, Dean Wampler, and Jason Rutherglen. “Programming Hive.” iBooks. 

Table: Hive namespaces for variables and properties.

```
[cloudera@quickstart temp]$ hive

Logging initialized using configuration in file:/etc/hive/conf.dist/hive-log4j.properties
hive> set env:HOME;
env:HOME=/home/cloudera
hive> set;
...
hive> set -v;
```

#### CLI's -e commands

```
$ hive -e "SELECT * FROM mytable LIMIT 3";
OK
name1 10
name2 20
name3 30
Time taken: 4.955 seconds
```

```
$ hive -S -e "select * FROM mytable LIMIT 3" > /tmp/myquery
$ cat /tmp/myquery
name1 10
name2 20
name3 30
```



#### CLI's -f commands

“Hive can execute one or more queries that were saved to a file using the -f file argument. By convention, saved Hive query files use the .q or .hql extension.”

Excerpt From: Edward Capriolo, Dean Wampler, and Jason Rutherglen. “Programming Hive.” iBooks. 

“If you are already inside the Hive shell you can use the SOURCE command to execute a script file. Here is an example:
$ cat /path/to/file/withqueries.hql
SELECT x.* FROM src x;
$ hive
hive> source /path/to/file/withqueries.hql;”

Excerpt From: Edward Capriolo, Dean Wampler, and Jason Rutherglen. “Programming Hive.” iBooks. 

#### Others

“The last CLI option we’ll discuss is the -i file option, which lets you specify a file of commands for the CLI to run as it starts, before showing you the prompt. Hive automatically looks for a file named .hiverc in your HOME directory and runs the commands it contains, if any.”

Excerpt From: Edward Capriolo, Dean Wampler, and Jason Rutherglen. “Programming Hive.” iBooks. 

“ tell the CLI to print column headers, which is disabled by default. We can enable this feature by setting the hiveconf property hive.cli.print.header to true:
hive> set hive.cli.print.header=true;

hive> SELECT * FROM system_logs LIMIT 3;
tstamp severity server message
1335667117.337715 ERROR server1 Hard drive hd1 is 90% full!
1335667117.338012 WARN  server1 Slow response from server2.
1335667117.339234 WARN  server2 Uh, Dude, I'm kinda busy right now...
If you always prefer seeing the headers, put the first line in your $HOME/.hiverc file.”

Excerpt From: Edward Capriolo, Dean Wampler, and Jason Rutherglen. “Programming Hive.” iBooks. 


“You can use the up and down arrow keys to scroll through previous commands. Actually, each previous line of input is shown separately; the CLI does not combine multiline commands and queries into a single history entry. Hive saves the last 100,00 lines into a file $HOME/.hivehistory.”

Excerpt From: Edward Capriolo, Dean Wampler, and Jason Rutherglen. “Programming Hive.” iBooks. 

“You don’t need to leave the hive CLI to run simple bash shell commands. Simply type ! followed by the command and terminate the line with a semicolon (;):
hive> ! /bin/echo "what up dog";
"what up dog"
hive> ! pwd;
/home/me/hiveplay
”

Excerpt From: Edward Capriolo, Dean Wampler, and Jason Rutherglen. “Programming Hive.” iBooks. 

“Don’t invoke interactive commands that require user input. Shell “pipes” don’t work and neither do file “globs.” For example, ! ls *.hql; will look for a file named *.hql;, rather than all files that end with the .hql extension.”

Excerpt From: Edward Capriolo, Dean Wampler, and Jason Rutherglen. “Programming Hive.” iBooks. 

“You can run the hadoop dfs ... commands from within the hive CLI; just drop the hadoop word from the command and add the semicolon at the end:
hive> dfs -ls / ;
Found 3 items
drwxr-xr-x   - root   supergroup          0 2011-08-17 16:27 /etl
drwxr-xr-x   - edward supergroup          0 2012-01-18 15:51 /flag
drwxrwxr-x   - hadoop supergroup          0 2010-02-03 17:50 /users
This method of accessing hadoop commands is actually more efficient than using the hadoop dfs ... equivalent at the bash shell, because the latter starts up a new JVM instance each time, whereas Hive just runs the same code in its current process.”

Excerpt From: Edward Capriolo, Dean Wampler, and Jason Rutherglen. “Programming Hive.” iBooks. 


#### Tips

“When working with small data sets, using local mode execution will make Hive queries much faster. Setting the property set hive.exec.mode.local.auto=true; will cause Hive to use this mode more aggressively, even when you are running Hadoop in distributed or pseudodistributed mode. To always use this setting, add the command to your $HOME/.hiverc file ”

“For very big files, if you want to view just the first or last parts, there is no -more, -head, nor -tail subcommand. Instead, just pipe the output of the -cat command through the shell’s more, head, or tail. For example: hadoop dfs -cat wc-out/* | more.”


“Suppose you can’t remember the name of the property that specifies the “warehouse” location for managed tables:
$ hive -S -e "set" | grep warehouse
hive.metastore.warehouse.dir=/user/hive/warehouse
hive.warehouse.subdir.inherit.perms=false”

Excerpt From: Edward Capriolo, Dean Wampler, and Jason Rutherglen. “Programming Hive.” iBooks.
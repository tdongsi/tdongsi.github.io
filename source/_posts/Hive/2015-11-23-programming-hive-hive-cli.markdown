---
layout: post
title: "Learning Hive (Pt. 2): Hive CLI"
date: 2015-11-23 19:47:23 -0800
comments: true
categories: 
- Book
- Hadoop
- Hive
---

This post covers how to get started with Hive and some basics of Hive, including its command-line interface (CLI).

<!--more-->

### Starting Hive with Cloudera Quickstart VM

On Cloudera Quickstart VM, the cores of its Hive distribution, including files such as `hive-exec*.jar` and `hive-metastore*.jar`, can be found in `/usr/lib/hive/lib`. 
The Hive executables can be found in `/usr/lib/hive/bin`. Running `hive` without any parameter will start Hive's CLI.
 
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

The `hive` shell command is actually a wrapper to multiple Hive services, including the CLI.

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

Note the list of services following the line "Service List". 
There are several services available, most notably **cli, hwi, jar, metastore**. 
You can use `--service name` option to invoke a service. 
CLI is the default service, not specifying any service in `hive` command will run CLI service, as shown in "Starting Hive" section above.

For example, to run [Hive Web Interface](https://cwiki.apache.org/confluence/display/Hive/HiveWebInterface), run the service **hwi**. On Cloudera Quickstart VM, you might encounter this error:

```
[cloudera@quickstart temp]$ hive --service hwi
ls: cannot access /usr/lib/hive/lib/hive-hwi-*.war: No such file or directory
15/11/23 20:22:50 INFO hwi.HWIServer: HWI is starting up
15/11/23 20:22:50 FATAL hwi.HWIServer: HWI WAR file not found at /usr/lib/hive/usr/lib/hive/lib/hive-hwi-0.8.1-cdh4.0.0.jar
```
To fix that error, edit the config file `hive-site.xml` in the `config` folder (e.g., `/usr/lib/hive/conf/hive-site.xml` on Cloudera VM) to point to the right location of HWI's `war` file. 
On Cloudera Quickstart VM, the `war` file property block should look like this:

```
...
 <property>
    <name>hive.hwi.war.file</name>
    <value>/lib/hive-hwi.jar</value>
    <description>This is the WAR file with the jsp content for Hive Web Interface</description>
  </property>
...
```
Running the **hwi** service again using `hive` command should work. In order to access the Hive Web Interface, go to `[Hive Server Address]`:9999/hwi on your web browser.

```
[cloudera@quickstart temp]$ hive --service hwi
ls: cannot access /usr/lib/hive/lib/hive-hwi-*.war: No such file or directory
15/11/23 20:31:27 INFO hwi.HWIServer: HWI is starting up
15/11/23 20:31:27 INFO mortbay.log: Logging to org.slf4j.impl.Log4jLoggerAdapter(org.mortbay.log) via org.mortbay.log.Slf4jLog
15/11/23 20:31:27 INFO mortbay.log: jetty-6.1.26.cloudera.4
15/11/23 20:31:27 INFO mortbay.log: Extract /usr/lib/hive/lib/hive-hwi.jar to /tmp/Jetty_0_0_0_0_9999_hive.hwi.0.13.1.cdh5.3.0.jar__hwi__.lcik1p/webapp
15/11/23 20:31:28 INFO mortbay.log: Started SocketConnector@0.0.0.0:9999
```

### Hive CLI

Available options for Hive CLI can be displayed as follows:

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

The `--define key=value` option is equivalent to the `--hivevar key=value` option. Both let you define custom variables in the `hivevar` namespace, separate from three other built-in namespaces, `hiveconf`, `system`, and `env`. By convention, the Hive namespaces for variables and properties are as follows:

1. hivevar: user-defined custom variables.
1. hiveconf: Hive-specific configuration properties.
1. system: Java configuration properties.
1. env: (Read-only) environment variables by shell environment (e.g., bash).

Inside Hive CLI, the command `SET` is used to display and change variables. For example:

```
[cloudera@quickstart temp]$ hive

Logging initialized using configuration in file:/etc/hive/conf.dist/hive-log4j.properties
hive> set env:HOME; <-- display HOME variable in env namespace
env:HOME=/home/cloudera
hive> set; <-- display all variables
...
hive> set -v; <-- display even more variables
...
hive> set hivevar:foo=bar; <-- set foo variable in hivevar namespace to bar
```


#### `-e query_string` and `-S` options

`-e` option allows you to execute a list of semicolon-separated queries as an input string. `-S` option for silent mode will remove non-essential output. For example:

```
$ hive -e "SELECT * FROM mytable LIMIT 3";
OK
name1 10
name2 20
name3 30
Time taken: 4.955 seconds
```

```
$ hive -S -e "select * FROM mytable LIMIT 3"
name1 10
name2 20
name3 30
```

**Tip**: To quickly search for the full name of a property that you only remember part of its name, pipe the Hive's `SET` command output to grep. For example:

```
[cloudera@quickstart temp]$ hive -S -e "set" | grep warehouse
hive.metastore.warehouse.dir=/user/hive/warehouse
hive.warehouse.subdir.inherit.perms=true
```

#### `-f script_file` option

This option allows you to execute one or more queries contained in a script file. If you are already within the Hive CLI, you can use the `SOURCE` command to execute a script file. For example:

```
$ cat /path/to/file/withqueries.hql
SELECT x.* FROM src x;
$ hive
hive> source /path/to/file/withqueries.hql;
``` 

#### `-i filename` option

This option lets you specify an initialization file with a list of commands for the CLI to run when it starts. The default initialization file is the file `$HOME/.hiverc` if it exists.

#### Tips

* To print column headers (disabled by default), set the hiveconf property `hive.cli.print.header` to true: `set hive.cli.print.header=true;`.
* Hive has a command history, saved into a file `$HOME/.hivehistory`. Use the up and down arrow keys to scroll through previous commands.
* To run HDFS commands from within Hive CLI, drop the hdfs. For example:

```
hive> dfs -ls input; 
Found 1 items
-rw-r--r--   1 cloudera cloudera         31 2015-01-15 18:04 input/wordcount.txt
```

* To run the bash shell commands from within Hive CLI, prefix `!` before the bash commands and terminate the line with a semicolon (;). Note that interactive commands, shell pipes `|`, and file globs `*` will not work. Example: 

```
hive> !pwd;
hive> /home/cloudera/temp
```

* Set the property `set hive.exec.mode.local.auto=true;` to use local mode more aggressively and gain performance in Hive queries, especially when working with small data sets.



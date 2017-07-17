---
layout: post
title: "Netezza CLI tools"
date: 2015-12-09 18:34:12 -0800
comments: true
categories:
- Database
---

In addition to using third party GUI clients such as SQuirreLSQL, you can also interact with Netezza through its command line interface (CLI) tools. 
These are programs that let you do useful things like importing and exporting large volumes of data, invoking Netezza from bash scripts, controlling sessions and queries, etc. 
The following is a quick overview of just the `nzsql` and `nzload` commands. 
For a description of all the CLI tools, see the documentation [here](http://www-01.ibm.com/support/knowledgecenter/SSULQD_7.2.0/com.ibm.nz.adm.doc/r_sysadm_summary_of_commands.html?lang=en). 
You can install the Netezza CLI tools directly onto your system by following the instructions [here](http://www-01.ibm.com/support/knowledgecenter/SSULQD_7.2.0/com.ibm.nz.adm.doc/c_sysadm_client_software_install.html).

<!--more-->

### nzsql command

You can use `nzsql` in interactive terminal mode by executing the command:

```
nzsql -host <hostname> -u <username> -pw <password> -d <database>
  
Welcome to nzsql, the IBM Netezza SQL interactive terminal.

Type:  \h for help with SQL commands
       \? for help on internal slash commands
       \g or terminate with semicolon to execute query
       \q to quit

ws(user)=>
```

which puts you in the nzsql command line interpreter.


From there, you can execute SQL commands: 

```
ws(user)=> select count(*) from dwh..companies;
COUNT
---------
6286
(1 row)
```

and you can also execute "slash" commands.  For example, to change the database to `dwh` and describe the table `companies`:
```
ws(user)=> \c dwh
You are now connected to database dwh.
ws(user)=> \d companies
                                 View "COMPANIES"
           Attribute           |          Type           | Modifier | Default Value 
-------------------------------+-------------------------+----------+---------------
 COMPANY_ID                    | NUMERIC(38,0)           | NOT NULL | 
 COMPANY_NAME                  | CHARACTER VARYING(100)  |          | 
 COMPANY_STATUS                | NUMERIC(38,0)           |          | 
 STATUS_MESSAGE                | CHARACTER VARYING(2000) |          | 
 CREATE_DATE                   | DATE                    |          | 
 CREATE_VERSION                | CHARACTER VARYING(20)   |          | 
 ASSIGNED_DATE                 | DATE                    |          | 
 ASSIGNED_VERSION              | CHARACTER VARYING(20)   |          | 
...
```

To see all the available slash commands, type `\?` at the prompt:

```
ws(user)=> \?
 \a              toggle between unaligned and aligned mode
 \act            show current active sessions
 \c[onnect] [dbname [user] [password]]	connect to new database (currently 'UED_QBO_WS')
 \C <title>      HTML table title
 \copy ...       perform SQL COPY with data stream to the client machine
 \d <table>      describe table (or view, index, sequence, synonym)
 \d{t|v|i|s|e|x} list tables/views/indices/sequences/temp tables/external tables
 \d{m|y}         list materialized views/synonyms
 \dS{t|v|i|s}    list system tables/views/indexes/sequences
 \dM{t|v|i|s}    list system management tables/views/indexes/sequences
 \dp <name>      list user permissions
 \dpu <name>     list permissions granted to a user
 \dpg <name>     list permissions granted to a group
 \dgp <name>     list grant permissions for a user
 \dgpu <name>    list grant permissions granted to a user
 \dgpg <name>    list grant permissions granted to a group
...
```
To escape from the nzsql interactive terminal mode, type `\q` at the prompt.

You can also use the `nzsql` command directly from the command line, by invoking it with various parameters. 
See the documentation [here](http://www-01.ibm.com/support/knowledgecenter/SSULQD_7.2.0/com.ibm.nz.adm.doc/r_sysadm_nzsql_command.html) for all the parameters that can be used with the `nzsql` command.
As an example, to execute a single SQL statement and print the results to the terminal: 

```
-bash-4.1$ nzsql -host myHost -u username -pw password -d ws -c 'select count(*) from companies'
COUNT  
---------
9032
(1 row)
```

Or, to direct the output to a specific file in the local file system:

```
-bash-4.1$ nzsql -host myHost -u username -pw password -d ws -c 'select count(*) from companies' -o output.txt
-bash-4.1$ cat output.txt
COUNT  
---------
9032
(1 row)
```

And, to run a SQL script that is located in the local file system:

```
-bash-4.1$ cat my_script.sql
select count(*) from companies;
-bash-4.1$ nzsql -host myHost -u username -pw password -d ws -f my_script.sql
COUNT
---------
9032
(1 row)
```

### nzload command

The `nzload` command is used to move large volumes of data in to and out of Netezza. 
This is a very broad subject, and you can find all the details [here](http://www-01.ibm.com/support/knowledgecenter/SSULQD_7.2.0/com.ibm.nz.load.doc/c_load_overview.html?cp=SSULQD_7.2.0%2F5&lang=en).
As a toy example, suppose you have the following data in the local filesystem:

```
-bash-4.1$ cat my_data.txt
Fred, 2
Betty, 7
Wilma, 10
Barney, 5
```

You can create a Netezza to hold this data, using the `nzsql` command:

```
-bash-4.1$ nzsql -host myHost -u username -pw password -d ws -c 'create table my_table (name varchar(80), rocks int)'
```

And then you can populate the table using the `nzload` command:

```
nzload -host myHost -u username -pw password -db ws -t my_table -df my_data.txt -delim ','
Load session of table 'MY_TABLE' completed successfully
```

Finally, you can confirm that the table was populated using the `nzsql` command:

```
-bash-4.1$ nzsql -host myHost -u username -pw password -d ws -c 'select * from my_table'
  NAME  | ROCKS 
--------+-------
 Wilma  |    10
 Betty  |     7
 Barney |     5
 Fred   |     2
(4 rows)
```

### External Links

1. [List of Netezza CLI tools](http://www-01.ibm.com/support/knowledgecenter/SSULQD_7.2.0/com.ibm.nz.adm.doc/r_sysadm_summary_of_commands.html?lang=en)
1. [Installing the Netezza CLI tools](http://www-01.ibm.com/support/knowledgecenter/SSULQD_7.2.0/com.ibm.nz.adm.doc/c_sysadm_client_software_install.html)
1. [Nzsql CLI tool](http://www-01.ibm.com/support/knowledgecenter/SSULQD_7.2.0/com.ibm.nz.adm.doc/r_sysadm_nzsql_command.html)
1. [Nzload CLI tool](http://www-01.ibm.com/support/knowledgecenter/SSULQD_7.2.0/com.ibm.nz.load.doc/c_load_overview.html?cp=SSULQD_7.2.0%2F5&lang=en)
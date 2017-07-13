---
layout: post
title: "Vertica tip: Using vsql CLI"
date: 2015-12-17 22:54:07 -0800
comments: true
published: true
categories: 
- Database
- Vertica
---

Some tips on using command-line tool `vsql` for connecting and interacting with Vertica database.

<!--more-->

### Using vsql

You can connect to Vertica database with username and password. When doing this, note that the password might be seen in the command history.

```
vsql -h internal.vertica.net -p 5433 -d VMart -U vertica_user -w password 
```

Or you can connect to Vertica with Kerberos authentication.

```
vsql -h internal.vertica.net -p 5433 -d VMart -k KerberosServiceName -K KerberosHostName
```

Note that from time to time, you could run into Kerberos GSI failure because the ticket expired. This is how you can renew and extend the ticket: run the following command to refresh Kerberos cache for the headless account `vertica_user`.

``` 
kinit -kt /home/path/to/vertica_user.keytab vertica_user@CORP.INTERNAL.NET
```

You can also run a single SQL command from command line with `-c` option or, alternatively, a SQL script file with multiple commands with `-f` option. 
These options can be very useful to automate in shell/python scripts. 
Note that you can also parameterize your scripts by using `-v` option to assign variables inside your SQL scripts. 

### Vsql meta commands

Here is list of commonly used vsql [meta commands](http://my.vertica.com/docs/7.0.x/HTML/index.htm#Authoring/ProgrammersGuide/vsql/Meta-Commands.htm):

```
dbadmin=> \dt — (list of all tables)
dbadmin=> \dt user* — (list of tables starting with user)
dbadmin=> \d tablename — (describe table)
dbadmin=> \dv — (list of all views)
```

Here are the vsql commands to export a file:

```
dbadmin=> \o sample_users_lists.csv
dbadmin=> \f|
dbadmin=> select * from my_dwh.users limit 20;
dbadmin=> \o
dbadmin=> \q
```

### External links

1. [Command line options](https://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/ConnectingToHPVertica/vsql/CommandLineOptions.htm)
1. [Meta Commands](http://my.vertica.com/docs/7.0.x/HTML/index.htm#Authoring/ProgrammersGuide/vsql/Meta-Commands.htm)
1. [Meta Commands: \d[Pattern]](http://my.vertica.com/docs/7.0.x/HTML/index.htm#Authoring/ProgrammersGuide/vsql/Meta-Commands/TheDPATTERNMeta-commands.htm)

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

### Using vsql

With username and password.

TODO: example

With Kerberos authentication.

TODO: example

Note that from time to time, we could run into Kerberos GSI failure because the ticket expired. This is how you can renew and extend the ticket: run the following command to refresh Kerberos cache for the headless account `vertica_user`.

``` 
kinit -kt /home/path/to/vertica_user.keytab vertica_user@CORP.INTERNAL.NET
```

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

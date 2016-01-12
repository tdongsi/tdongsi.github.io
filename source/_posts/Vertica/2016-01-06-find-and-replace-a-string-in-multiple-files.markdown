---
layout: post
title: "Find and replace a string in multiple files"
date: 2016-01-06 23:49:15 -0800
comments: true
categories: 
- Vertica
- CentOS
- MacOSX
- Ubuntu
- Git
---

### Vertica Virtual Machine as sandbox test environment

When developing data-warehouse solutions in Vertica, you want to set up some test environment.
Ideally, you should have separate schema for each developer. 
However, it is usually NOT possible in my experience: developers and test engineers have to share very few schemas in development environment. 
The explanation that I usually get is that having a schema for each developer will not scale in database maintainance and administration, and there are likely some limits in Vertica's commercial license. 
If that is the case, I recommend that we look into using Vertica Community Edition on **Virtual Machines (VMs)** for sandbox test environment, as a cheap alternative.

Are VMs really necessary in data-warehouse testing? When testing Extract-Transform-Load (ETL) processes, I find that many of test cases require regular set-up and tear-down, adding mock records to represent corner cases, and/or running ETLs multiple times to simulate daily runs of those processes. 
Regular tear-down requires dropping multiple tables regularly, which requires much greater care and drains much mental energy when working with others' data and tables. 
Similarly, adding mock records into some commonly shared tables might affect others when they assume the data is production-like.
Running ETL scripts regularly, which could be computationally intensive, on a shared Vertica cluster might affect the performance or get affected by others' processes.

In short, for these tests, I cannot use the common schema that is shared with others since it might interfere others and/or destroy valuable common data. 
Using a Vertica VM as the sandbox test environment helps us minimize interference to and from others' data and activities.

### Single-node VM and KSAFE clause

I have been using a **single-node** Vertica VM to run tests for sometime. And it works wonderfully for testing purpose, especially when you want to isolate issues, for example, a corner case. This Vertica VM can be downloaded from HP Vertica's support website (NOTE: As of 2016 Jan 1st, the Vertica 7.1 VM is taken down while the Vertica 7.2 VM is not avaialble).
The only minor problem is when we add `KSAFE 1` in our DDL scripts (i.e., `CREATE TABLE` statements) for production purposes which gives error on single-node VM when running DDL scripts to set up schema.
The reason is that Vertica database with 1 or 2 hosts cannot be *k-safe* (i.e., it may lose data if it crashes) and three nodes are the minimum requirement to have `KSAFE 1` in `CREATE TABLE` statements to work.

Even then, the workaround for running those DDL scripts in tests is easy enough if all DDL scripts are all located in a single folder. The idea is that since `KSAFE 1` does not affect ETL processes's logics, we can remove those KSAFE clauses to set up the test schema and go ahead with our ETL testing. Specifically, in my project, my workflow for ETL testing with **Git** is as follows:

* Branch the latest code (develop branch) into a temporary branch (local/develop branch).
* Find and replace `KSAFE 1` in all DDL files (see subsection below).
* Commit this change in local/develop branch with some unique description. For example, "KSAFE REMOVAL".
* Add unit and functional tests to ETL scripts in this branch.
* After tests are properly done and checked-in, reverse "KSAFE REMOVAL" commit above. 
  * In SourceTree, it could be done by a simple right-click on that commit and selecting "Reverse Commit".
* Merge local/develop branch into develop branch. You will now have your tests with the latest codes in develop branch.

#### Find and replace a string in multiple files

```
grep -rl matchstring somedir/ | xargs sed -i 's/string1/string2/g'
```

Note: The forward slash '/' delimiter in the sed argument could also be a different delimiter (such as the pipe '|' character). The pipe delimiter might be useful when searching through a lot of html files if you didn't want to escape the forward slash, for instance.

matchstring is the string you want to match, e.g., "football" string1 would ideally be the same string as matchstring, as the matchstring in the grep command will pipe only files with matchstring in them to sed. string2 is the string that replace string1. There may be times when you want to use grep to find only files that have some matchstring and then replace on a different string in the file than matchstring. For example, maybe you have a lot of files and only want to only replace on files that have the matchstring of 'phonenumber' in them, and then replace '555-5555' with '555-1337'. Not that great of an example (you could just search files for that phone number instead of the string 'phonenumber'), but your imagination is probably better than mine.

Example

```
grep -rl 'windows' ./ | xargs sed -i 's/windows/linux/g'
```

This will search for the string 'windows' in all files relative to the current directory and replace 'windows' with 'linux' for each occurrence of the string in each file.

#### Remove KSAFE

An special case of "Find and replace" command is "Find and remove". 

Example:

grep -rl 'KSAFE 1' table | xargs sed -i 's/KSAFE 1//g'



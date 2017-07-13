---
layout: post
title: "Using Virtual Machine for ETL testing"
date: 2016-01-10 23:49:15 -0800
comments: true
categories: 
- Vertica
- CentOS
- MacOSX
- Git
- Bash
- Testing
---

When developing data-warehouse solutions in Vertica, you want to set up some test environment.
Ideally, you should have separate schema for each developer. 
However, it is usually NOT possible in my experience: developers and test engineers have to share very few schemas in development environment. 
The explanation that I usually get is that having a schema for each developer will not scale in database maintenance and administration, and there are likely some limits in Vertica's commercial license. 
If that is the case, I recommend that we look into using Vertica Community Edition on **Virtual Machines (VMs)** for sandbox test environment, as a cheap alternative.

<!--more-->

### Vertica Virtual Machine as sandbox test environment

Are VMs really necessary in data-warehouse testing? When testing Extract-Transform-Load (ETL) processes, I find that many of test cases require regular set-up and tear-down, adding mock records to force rare logical branches and corner cases, and/or running ETLs multiple times to simulate daily runs of those processes. 
Regular tear-down requires dropping multiple tables regularly, which requires much greater care and drains much mental energy when working with others' data and tables. 
Similarly, adding mock records into some commonly shared tables might affect others when they assume the data is production-like.
Running ETL scripts regularly, which could be computationally intensive, on a shared Vertica cluster might affect the performance or get affected by others' processes.
In short, for these tests, I cannot use the common schema that is shared with others since it might interfere others and/or destroy valuable common data. 
Using a Vertica VM as the sandbox test environment helps us minimize interference to and from others' data and activities.

### Single-node VM and KSAFE clause

I have been using a **single-node** Vertica VM to run tests for sometime. And it works wonderfully for testing purpose, especially when you want to isolate issues, for example, a corner case. The Vertica VM can be downloaded from HP Vertica's support website (NOTE: As of 2016 Jan 1st, the Vertica 7.1 VM is taken down while the Vertica 7.2 VM is not available).

The only minor problem is when we add `KSAFE 1` in our DDL scripts (i.e., `CREATE TABLE` statements) for production purposes. This gives error on single-node VM when running DDL scripts to set up schema.
The reason is that Vertica database with one or two hosts cannot be *k-safe* (i.e., it may lose data if it crashes) and three-node cluster is the minimum requirement to have `KSAFE 1` in `CREATE TABLE` statements to work.

Even then, the workaround for running those DDL scripts in tests is easy enough if all DDL scripts are all located in a single folder. The idea is that since `KSAFE 1` does not affect ETL processes' transform logics, we can remove those KSAFE clauses to set up the test schema and go ahead with our ETL testing. Specifically, in my project, my workflow for ETL testing with **Git** is as follows:

* Branch the latest code (`develop` branch) into a temporary branch (e.g., `local/develop` branch).
* Find and remove `KSAFE 1` in all DDL files (see subsection below).
* While still in `local/develop` branch, commit all these changes in a **single** commit with some unique description (e.g., "KSAFE REMOVAL").
* Add unit and functional tests to ETL scripts in this branch.
* After tests are properly developed and checked-in, reverse the "KSAFE REMOVAL" commit above. 
  * In SourceTree, it could be done by a simple right-click on that commit and selecting "Reverse Commit".
* Merge `local/develop` branch into `develop` branch (create a pull request if needed). You will now have your tests with the latest codes in `develop` branch.

#### Find and replace a string in multiple files

There are times and times again that you find that you have to replace every single occurrences of some string in multiple files with another string. Finding and removing `KSAFE 1` like the above workflow is an example where "removing string" is a special case of "replacing string" with nothing. This operation can be quickly done by the following bash command:

```
grep -rl match_string your_dir/ | xargs sed -i 's/old_string/new_string/g'
```

If you are familiar with bash scripting, the above command is straight forward. This quick explanation is for anyone who does not understand the command:

* `grep` command finds all files in `your_dir` directory that contain `match_string`. `-l` option makes sure it will return a list of files
* `sed` command then execute the replacement regex on all those files. A regex tip: the forward slash `/` delimiter could be another delimiter (e.g., `#`). This might be useful if you need to search HTML files.

Example: In my case, all the DDL scripts are in multiple sub-directories under `tables` directory. To find and remove all `KSAFE 1` occurrences, the command is:

```
grep -rl 'KSAFE 1' tables | xargs sed -i 's/KSAFE 1//g'
```

This will search for the string `KSAFE 1` in all files in the `tables` directory and replace `KSAFE 1` with nothing `''` for each occurrence of the string in each file.


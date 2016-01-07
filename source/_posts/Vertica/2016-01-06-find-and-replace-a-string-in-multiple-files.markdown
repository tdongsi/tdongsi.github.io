---
layout: post
title: "Find and replace a string in multiple files"
date: 2016-01-06 23:49:15 -0800
comments: true
categories: 
- Vertica
- CentOS
---

## Vertica VM as sandbox test environment

When developing data-warehouse solutions in Vertica, you want to set up some test environment.
Ideally, you should have separate schema for each developer. 
However, it is usually NOT possible in my experience: developers and test engineers have to share very few schemas in development environment. 
The explanation that I usually get is that having each schema for each developer will not scale in database maintainance and administration, and there are likely some limits in Vertica's commercial license. 
If that is the case, I recommend that we look into using Vertica Community Edition on Virtual Machines (VMs) for sandbox test environment, as a cheap alternative.

When testing Extract-Transform-Load (ETL) processes, I find that many of test cases require regular set-up and tear-down, adding mock records to represent corner cases, and running ETLs multiple times to simulate daily runs of those processes. 
For these tests, I cannot use the common schema that is shared with others since it might interfere others and/or destroy valuable common data. 
My solution is to use Vertica VMs as sandbox test environment for those tests. 

## Single-node VM and KSAFE clause

I have been using a **single-node** Vertica VM to run tests for sometime. And it works wonderfully for testing purpose, especially when you want to isolate issues, e.g., a corner case. 
The only minor problem is when we add `KSAFE 1` in our DDL scripts (i.e., `CREATE TABLE` statements) for production purposes which gives error on single-node VM when running DDL scripts to set up schema.
The reason is that Vertica database with 1 or 2 hosts cannot be *k-safe* (i.e., it may lose data if it crashes) and three nodes are the minimum requirement to have `KSAFE 1` in `CREATE TABLE` statements to work.

Even then, the workaround for running those DDL scripts in tests is easy enough if all DDL scripts are all located in a single folder.

### Find and replace a string in multiple files
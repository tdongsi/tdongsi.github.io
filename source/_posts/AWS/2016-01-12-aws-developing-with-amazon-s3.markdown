---
layout: post
title: "AWS: Developing with Amazon S3"
date: 2016-01-12 17:13:28 -0800
comments: true
published: false
categories: 
- AWS
---

http://docs.aws.amazon.com/AmazonS3/latest/dev/ListingKeysHierarchy.html

### Lab 1

``` bash
MTVL1288aeea2-82:~ cdongsi$ chmod 400 ~/Downloads/qwikLABS-L1014-387088.pem
MTVL1288aeea2-82:~ cdongsi$ ssh -i ~/Downloads/qwikLABS-L1014-387088.pem ec2-user@52.33.62.25
The authenticity of host '52.33.62.25 (52.33.62.25)' can't be established.
RSA key fingerprint is 59:40:98:24:8f:96:b4:13:95:c4:3d:f6:e0:87:be:2b.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '52.33.62.25' (RSA) to the list of known hosts.

       __|  __|_  )
       _|  (     /   Amazon Linux AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-ami/2015.09-release-notes/
11 package(s) needed for security, out of 27 available
Run "sudo yum update" to apply all updates.


Credentials Profile file
[ec2-user@ip-10-0-10-236 ~]$ cat ~/.aws/credentials
[default]
aws_access_key_id=ASYX4NadfasdCSUVOQlkjsldkjfa
aws_secret_access_key=RSPh45sfadsf0yVYBv+xiTasdfas8n5cyZufUrptFaZ

Default Region
[ec2-user@ip-10-0-10-236 ~]$ cat ~/.aws/config
[default]
region = us-west-2
```

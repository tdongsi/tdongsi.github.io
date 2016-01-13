---
layout: post
title: "AWS: Building the Foundation"
date: 2016-01-11 18:36:45 -0800
comments: true
published: false
categories: 
- AWS
---

Not all Amazon Web Services (AWS) are equal. This will list only important AWS's.

From bottom up:

* AWS Global Infrastructure
* Foundation Services
* Platform Services

### Foundation Services

#### Networking

Amazon VPC: Virtual Private Cloud, virtual networking environment. Interaction with EC2 instances as if you are in the same existing network.

Amazon Route 53: DNS service.

#### Storage

Elastic File System allows you to modify to the block level. EBS does not allow that.
EBS cannot be connected to multiple EC2 instances. One Elastic File System instance can be connected to multiple EC2 instances.

``` plain http://stackoverflow.com/questions/2288402/should-i-persist-images-on-ebs-or-s3
EBS means you need to manage a volume + machines to attach it to. You need to add space as it's filling up and perform backups (not saying you shouldn't back up your S3 data, just that it's not as critical).

It also makes it harder to scale: when you want to add additional machines, you either need to pull off the images to a separate machine or clone the images across all. This also means you're adding a bottleneck: you'll have to manage your own upload process that will either upload to all machines or have a single machine managing it.
```

S3 is mostly recommended for static files: like a FTP service. You might want to use EBS if you have a private application that requires private read/write access to some storage.

CloudFront: is a content delivery service, working like a cache for frequently accessed web pages or images to reduce latency.

Glacier: different from S3: in S3, files are frequently accessed. Glacier is a cold storage for infrequently accessed files, for archiving. 
It takes much longer to access Glacier files than S3.

It is possible and actually recommended to bundle many files/objects into one archive before storing to Glacier. 

#### Administration

CloudWatch: Monitoring metrics and performance.

CloudTrail

### Platform Services

#### Databases

RDS: 

[**ElastiCache**](https://aws.amazon.com/elasticache/)

You pay more for better performance. It can imporve performance of web applications by allowing you to retrieve information from memory-based cache nodes instead of relying entirely on slower disk-based databases. It supports Memcached and Redis caching engine.

### AWS Global Infrastructure

http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html

11 Regions: Each region has at least 2 AZs. Regions are separate from each other: e.g., you cannot access China or Government regions without special permissions.

53 Edge locations: for CloudFront and Route 53 services.

Availability Zones: Physical data center.

https://forums.aws.amazon.com/thread.jspa?threadID=91845

An AWS region contains two or more availability zones. Each zone is basically a separate datacenter, and provides low latency connectivity to all other zones in the region. Your resources, such as EC2 instances, reside in the region of your choice. The AWS regions are isolated from each other, but you can seamlessly manage resources in different availability zones within the same region.

Edge locations serve requests for CloudFront and Route 53. CloudFront is a content delivery network, while Route 53 is a DNS service. Requests going to either one of these services will be routed to the nearest edge location automatically. This allows for low latency no matter where the end user is located.

S3 stores your data in multiple availability zones within your region of choice. The US Standard region works a bit different though, as it uses both the East and West coast.

### Amazon Resource Name

Some services are global, such as S3. Those services do not require a region specified.


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




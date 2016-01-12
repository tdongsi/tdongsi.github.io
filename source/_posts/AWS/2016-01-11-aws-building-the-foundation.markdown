---
layout: post
title: "AWS: Building the Foundation"
date: 2016-01-11 18:36:45 -0800
comments: true
published: false
categories: 
- AWS
---

### Foundation Services

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

##### Administration

CloudWatch: Monitoring metrics and performance.

### Platform Services

#### Databases

RDS: 

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



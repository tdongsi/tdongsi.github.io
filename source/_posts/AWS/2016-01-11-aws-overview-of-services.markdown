---
layout: post
title: "AWS: Overview of Services"
date: 2016-01-14 18:36:45 -0800
comments: true
published: true
categories: 
- AWS
---

Amazon Web Services (AWS) is a collection of web services that deliver computing resources (hardware and software) to end-users over the Internet. 
Not all AWS are equal but for AWS beginners, we usually don't know which are more important and which are secondary, supporting services. 
Personally, I am initially overwhelmed by the number of services offered as well as large amount of documentation associated with each service.

This post documents my understanding on some key AWS services and concepts. In this post, AWS concepts and services can be divided into layers. Those layers, from bottom up, are:

* AWS Infrastructure: Physical data centers and physical network connections.
* Infrastructure Services (IaaS). 
* Platform Services (PaaS).

### AWS Global Infrastructure

AWS are available in many locations world-wide. These locations are divided into [regions and Availability Zones](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html). 
As of January 2016, there are 11 regions, each **region** contains two or more Availability Zones. 
Your resources, such as EC2 instances, reside in the region of your choice.
AWS regions are isolated from each other and you usually cannot access resources in another region. 
Furthermore, some newer services may be available in some regions while not in others.

Each **Availability Zone** (AZ) is basically a separate physical data center, and provides low latency connectivity to all other AZs in the same region. 
Although you cannot access resources in another region, but you can seamlessly manage resources in different AZs within the same region. 
It is recommended that you provision your resources across multiple AZs to achieve redundancy. When a single AZ has a problem, your resources will be still available in other AZs. 
For example, S3 stores your data in multiple AZs within your region of choice.

**Edge locations** serve requests for CloudFront and Route 53 services. CloudFront is a content delivery network 
(CDN), while Route 53 is a DNS service. 
Requests going to either one of these services will be automatically routed to the nearest edge location (out of 53 available edge locations, as of Jan 2016). This allows for low latency no matter where the end user is located.

### Infrastructure Services

AWS offerings are divided into two large groups: Infrastructure and Platform, which are further divided into different categories. 
In addition to plain explanation to each service, I added its typical non-cloud, closest equivalent applications or technologies in "Use it like" column next to "AWS name" column.
Note that they are just analogies, purely for illustration purposes.
The official service names are in bold (e.g., EC2 and S3), while their respective full names (e.g., Elastic Compute Cloud and Simple Storage Service, respectively) are in parentheses.

The grouping of Amazon Web Services as below is purely for review purpose (and remembering their numerous acronyms and names) since these services rarely work alone or are limited to a small group of services. 
For example, EC2 instances are usually deployed in some Auto Scaling Groups, all of these groups are in some VPC, accepting traffic from some ELBs.
In a more sophisticated example, you can have some web application running on EC2 instances which store application data in Amazon DynamoDB which, in turn, store its index in some Amazon S3 buckets. 
This Amazon DynamoDB have some database "triggers" implemented with AWS Lambda. These services can be monitored for performance using CloudWatch and access-controlled by IAM.
These examples show that how these AWS offerings can be inter-dependent and inter-connected in practice.

#### Compute

| AWS name | Use it like | Notes |
| --- | --- | --- |
| **Amazon EC2** <br/>(Elastic Compute Cloud) | Application server | Remote, virtual server instances. <br/>[What is EC2](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html) <br/>[Instance types](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html) <br/>[Tags](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Using_Tags.html) <br/>[Key Pairs](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) <br/>[EC2 and VPC](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-vpc.html) <br/>[AMI](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instances-and-amis.html)
| **Amazon ELB** <br/>(Elastic Load Balancing) |  | Incoming traffic load balancing. <br/>[ELB](http://docs.aws.amazon.com/ElasticLoadBalancing/latest/DeveloperGuide/how-elb-works.html) <br/>[ELB Terms and Concepts](http://docs.aws.amazon.com/ElasticLoadBalancing/latest/DeveloperGuide/how-elb-works.html)|
| **AWS Lambda** |  | Like a cluster of one node.|
| **Amazon EC2 <br/>Container Service** | | Deployment Service |
| **Auto Scaling** | | Scaling <br/>[Auto Scaling Group](http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/how-as-works.html)|

<br/>

#### Networking

| AWS name | Use it like | Notes |
| --- | --- | --- |
| [**VPC**](http://aws.amazon.com/vpc/) <br>(Virtual Private Cloud) | VLAN | Virtual networking environment. <br/>Interaction with EC2 instances as if you are in the same existing network. |
| **Amazon Route 53** | DNS server | DNS service. |
| **AWS Direct Connect** | | |
| **Amazon CloudFront** | CDN | Content delivery service. <br/>Working like a cache for frequently accessed web pages or images to reduce latency. |

<br/>
#### Storage

| AWS name | Use it like | Notes |
| --- | --- | --- |
| [**Amazon S3**](http://aws.amazon.com/s3/) <br/>(Simple Storage Service) | FTP server. | Object store. Not a file system like EBS. <br/> More on [S3 vs. EBS](http://stackoverflow.com/questions/2288402/should-i-persist-images-on-ebs-or-s3).|
| **Amazon EBS** <br/>(Elastic Block Storage) | Hard drive to EC2. | Block storage. You can choose file system to format. <br/>You need a EC2 instance attach to it. |
| [**Glacier**](http://aws.amazon.com/glacier/) | [Tape backup](https://en.wikipedia.org/wiki/Memory_hierarchy). | Cold storage for archives, i.e., infrequently accessed files. <br/>It takes much longer to access Glacier files than S3.|
| **Elastic File System** | File system. | Currently in Preview. <br/>EBS cannot be connected to multiple EC2 instances. <br/>One Elastic File System instance can be connected to multiple EC2 instances. <br/> More on [EFS vs. EBS vs. S3](http://stackoverflow.com/questions/29575877/aws-efs-vs-ebs-vs-s3-differences-when-to-use).|

<br/>

<!-- 
EBS means you need to manage a volume + machines to attach it to. You need to add space as it's filling up and perform backups (not saying you shouldn't back up your S3 data, just that it's not as critical).

It also makes it harder to scale: when you want to add additional machines, you either need to pull off the images to a separate machine or clone the images across all. This also means you're adding a bottleneck: you'll have to manage your own upload process that will either upload to all machines or have a single machine managing it.

S3 is mostly recommended for static files: like a FTP service. You might want to use EBS if you have a private application that requires private read/write access to some storage.
-->

#### Administration & Security

| AWS name | Use it like | Notes |
| --- | --- | --- |
| [**AWS IAM**](http://aws.amazon.com/iam/)| | Manage users, keys, and certificates. <br/>You can set up additional users and new AWS keys, modify policies. <br/>Follow [Best Practices](http://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)|
| **CloudWatch** | | Monitoring metrics and performance. |
| **CloudTrail** | | Logging calls to services. |

<br/>

#### Applications

| AWS name | Use it like | Notes |
| --- | --- | --- |
| **WorkSpaces** | VirtualBox <br/>Remote Desktop | Desktop as a Service. <br/> Cloud-based desktop service with installed common applications. |
| **WorkDocs** | | |

<br/>

### Platform Services

#### Databases

| AWS name | Use it like | Notes |
| --- | --- | --- |
| [**RDS**](https://aws.amazon.com/rds/) <br/>(Relational Database Service) | MySQL, PostgreSQL, etc. <br/>Relational databases. | Managed relational databases in the cloud. <br/>Amazon Aurora, Oracle, Microsoft SQL Server, PostgreSQL, MySQL and MariaDB.|
| [**Aurora**](https://aws.amazon.com/rds/aurora/) | Managed MySQL. | MySQL users can import their data. |
| [**ElastiCache**](https://aws.amazon.com/elasticache/)| Memcached. Redis. | For information retrieval from memory-based cache nodes instead of slower disk-based databases. <br/>It supports Memcached and Redis caching engine. |
| [**DynamoDB**](https://aws.amazon.com/dynamodb/) | MongoDB | Managed NoSQL database service. |
| [**Redshift**](https://aws.amazon.com/redshift/) | OLAP system | Data warehouse service. |

<br/>

#### Analytics

| AWS name | Use it like | Notes |
| --- | --- | --- |
| **Kinesis** | | |
| [**EMR**](https://aws.amazon.com/elasticmapreduce/) <br/>(Elastic MapReduce) | MapReduce. HBase. | Big Data processing. <br/>Spark is also available.|
| **Data Pipeline** | | |

<br/>

#### App Services

| AWS name | Use it like | Notes |
| --- | --- | --- |
| **Cloud Search** | | |
| **SES** | | |
| **SWF** | | |
| **Elastic Transcoder** | | |

<br/>

#### Deployment & Management

| AWS name | Use it like | Notes |
| --- | --- | --- |
| **Code Commit** | Git | Source control service.|
| **Code Deploy** | | Code deployment service. |
| **CloudFormation** | Chef (in JSON) | Infrastructure as Code. <br/>Provisioning using source-controlled codes.|
| **Elastic Beanstalk** | CloudFormation simplified for WebApps. | Higher-level of CloudFormation for web applications. <br/>Example usage: Blue-Green deployment (easier than CloudFormation).  |
| **OpsWork** | Chef | Higher-level of CloudFormation. <br/>Configuration Management.  |

<br/>

#### Mobile Services

| AWS name | Use it like | Notes |
| --- | --- | --- |
| **SNS** | | Notifications. |
| **Cognito** | | Mobile authentication and data syncing. |
| **Mobile Analytics** | | Measure and analyze mobile application usage data. |

---
layout: post
title: "AWS: Overview of Services"
date: 2016-01-11 18:36:45 -0800
comments: true
published: true
categories: 
- AWS
---

Amazon Web Services (AWS) is a collection of web services that deliver computing resources (hardware and software) to end-users over the Internet. 
Not all AWS are equal but for AWS beginners, we usually don't know which are more important and which are secondary, supporting services. 
Personally, I am initially overwhelmed by the number of services offered as well as large amount of documenation associated with each service.

This post documents my understanding on some key AWS services and concepts. In this post, AWS concepts and services can be divided into layers. Those layers, from bottom up, are:

* AWS Infrastructure: Physical data centers and physical network connections.
* Foundation Services: Infrastructures as Services. 
* Platform Services: Platform as Services.

### AWS Global Infrastructure


http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html

11 Regions: Each region has at least 2 AZs. Regions are separate from each other: e.g., you cannot access China or Government regions without special permissions.

53 Edge locations: for CloudFront and Route 53 services.

Availability Zones: Physical data center.

https://forums.aws.amazon.com/thread.jspa?threadID=91845

An AWS region contains two or more availability zones. Each zone is basically a separate data center, and provides low latency connectivity to all other zones in the same region. Your resources, such as EC2 instances, reside in the region of your choice. The AWS regions are isolated from each other, but you can seamlessly manage resources in different availability zones within the same region.

It is recommended that you provision your resources across multiple Availability Zones and get redundancy. If a single AZ has a problem, your resources and assets in other AZs will not be affected.

Edge locations serve requests for CloudFront and Route 53. CloudFront is a content delivery network 
(CDN), while Route 53 is a DNS service. Requests going to either one of these services will be routed to the nearest edge location automatically. This allows for low latency no matter where the end user is located.

S3 stores your data in multiple availability zones within your region of choice.

### Foundation Services

In addition to plain explanation to each service, I added its typical non-cloud, closest equivalent applications or technologies in "(*Equivalent*: technology name)" string next to each service name. 
Note that they are just analogies, purely for illustration purposes. Some are not exactly equivalent since some of these AWS can work closely with each other.

"To implement sophisticated solutions, you can integrate DynamoDB with other services as follows:
•	Object index: Integrate DynamoDB with Amazon S3 to maintain an index of objects in your S3 bucket.
•	Triggers: Integrate DynamoDB with AWS Lambda to automatically execute a custom function when item-level changes occur. For example, you can use this functionality to send a notification or to update an aggregate table every time a change occurs.
•	Search: Integrate DynamoDB with Amazon Elasticsearch Service to enable free- text search of DynamoDB content. You can also integrate with Amazon CloudSearch to search DynamoDB content.
•	Monitoring: Integrate DynamoDB with Amazon CloudWatch to view throughput and latency and send alarms when there is a sudden surge in usage.
•	Fine-grained access control: Integrate DynamoDB with AWS Identity and Access Management (IAM) to grant access to DynamoDB resources and API operations."
 (AWS 110)

AWS. Developing on AWS 2.0 (EN): Student Guide. AWS/Gilmore. VitalBook file.



#### Compute

* **Amazon EC2 (Elastic Compute Cloud)** (*Equivalent*: Application server): Remote, virtual server instances.
* **Amazon ELB (Elastic Load Balancing)**
* **AWS Lambda**
* **Amazon EC2 Container Service**
* **Auto Scaling**

More on EC2:

* [What is EC2](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/concepts.html)
* [Instance types](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/instance-types.html)
* [Tags](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Using_Tags.html)
* [Key Pairs](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)
* [EC2 and VPC](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-vpc.html)
* [AMI](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instances-and-amis.html)
* [ELB](http://docs.aws.amazon.com/ElasticLoadBalancing/latest/DeveloperGuide/how-elb-works.html)
* [ELB Terms and Concepts](http://docs.aws.amazon.com/ElasticLoadBalancing/latest/DeveloperGuide/how-elb-works.html)
* [Auto Scaling Group](http://docs.aws.amazon.com/AutoScaling/latest/DeveloperGuide/how-as-works.html)

#### Networking

* [**VPC**](http://aws.amazon.com/vpc/) (*Equivalent*: VLAN): Virtual Private Cloud, virtual networking environment. Interaction with EC2 instances as if you are in the same existing network. You can create private subnets and VPN tunnels between your home network and your AWS VPC.
* **Amazon Route 53** (*Equivalent*: DNS server): DNS service.
* **AWS Direct Connect**
* **Amazon CloudFront** (*Equivalent*: CDN): CloudFront is a content delivery service, working like a cache for frequently accessed web pages or images to reduce latency.

#### Storage

* **Amazon EBS**
* **Amazon S3** (*Equivalent*: FTP server):
* **Elastic File System** allows you to modify to the block level. EBS does not allow that. EBS cannot be connected to multiple EC2 instances. One Elastic File System instance can be connected to multiple EC2 instances.
* **Glacier**: different from S3: in S3, files are frequently accessed. Glacier is a cold storage for infrequently accessed files, for archiving. It takes much longer to access Glacier files than S3.It is possible and actually recommended to bundle many files/objects into one archive before storing to Glacier.

``` plain http://stackoverflow.com/questions/2288402/should-i-persist-images-on-ebs-or-s3
EBS means you need to manage a volume + machines to attach it to. You need to add space as it's filling up and perform backups (not saying you shouldn't back up your S3 data, just that it's not as critical).

It also makes it harder to scale: when you want to add additional machines, you either need to pull off the images to a separate machine or clone the images across all. This also means you're adding a bottleneck: you'll have to manage your own upload process that will either upload to all machines or have a single machine managing it.
```

S3 is mostly recommended for static files: like a FTP service. You might want to use EBS if you have a private application that requires private read/write access to some storage.

#### Administration & Security

* [**AWS IAM**](http://aws.amazon.com/iam/): Manage users, keys, and certificates. You can set up additional users and new AWS keys, modify policies. 
  * Follow this [Best Practices](http://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
* **CloudWatch**: Monitoring metrics and performance.
* **CloudTrail**: Logging calls to services.

#### Applications

* **WorkSpaces**
* **WorkDocs**

### Platform Services

#### Databases

* [**RDS**](somelinke) (*Equivalent*: MySQL, Oracle, any relational database): 
* [**ElastiCache**](https://aws.amazon.com/elasticache/) (*Equivalent*: Memcached):
  * You pay more for better performance. It can imporve performance of web applications by allowing you to retrieve information from memory-based cache nodes instead of relying entirely on slower disk-based databases. It supports Memcached and Redis caching engine.
* **DynamoDB** (*Equivalent*: MongoDB): NoSQL database service.
* **Redshift** (*Equivalent*: OLAP system): data warehouse service.

#### Analytics

* **Kinesis**
* **EMR**
* **Data Pipeline**

#### App Services

* **Cloud Search**
* **SES**
* **SWF**
* **Elastic Transcoder**

#### Deployment & Management

* **Code Commit** (*Equivalent*: Git, source control)
* **Code Deploy**
* **CloudFormation** (*Equivalent*: Chef)
* **Elastic Beanstalk**

#### Mobile Services

* **SNS**: notifications
* **Cognito**: mobile authentication and data syncing.
* **Mobile Analytics**

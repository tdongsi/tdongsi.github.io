---
layout: post
title: "AWS: Connecting Applications and Data"
date: 2016-01-11 18:37:02 -0800
comments: true
published: false
categories: 
- AWS
---

Amazon Kinesis Streams.



### Amazon Resource Name

Some services are global, such as S3. Those services do not require a region specified.

"The components of the ARN are: •	Partition: The partition that the resource is in. For standard AWS regions, the
partition is aws. If you have resources in other partitions, the partition is aws- partitionname. For example, the partition for resources in the China (Beijing) region is aws-cn.
•	Service: The service namespace that identifies the AWS product (for example, s3, dynamodb).
•	Region: The region that the resource resides in (for example, us-west-2). Note that the ARNs for some resources do not require a region, so this component might be omitted.
•	Account: The ID of the AWS account that owns the resource, without the hyphens, for example, 123456789012. Note that the ARNs for some resources don't require an account number, so this component might be omitted.
•	Resource, resourcetype:resource, or resourcetype/resource: The content of this part of the ARN varies by service. It often includes an indicator of the type of resource—for example, an Amazon DynamoDB table or Amazon S3 bucket — followed by a slash (/) or a colon (:), followed by the resource name itself (for example, table/accounts, survey_bucket/*) . Some services allows paths for resource names."
 (AWS 27)

AWS. Developing on AWS 2.0 (EN): Student Guide. AWS/Gilmore. VitalBook file.

http://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html
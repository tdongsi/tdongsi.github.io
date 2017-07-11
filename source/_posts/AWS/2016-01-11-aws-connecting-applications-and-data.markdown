---
layout: post
title: "AWS: Amazon Resource Name"
date: 2016-01-19 18:37:02 -0800
comments: true
published: true
categories: 
- AWS
---

The [Amazon Resource Name](http://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html) (ARN) is used to uniquely identify an AWS resource. You will need to use ARNs to connect your services and data in AWS.

<!--more-->

Format:

* arn:partition:service:region:account-id:resource
* arn:partition:service:region:account-id:resourcetype/resource
* arn:partition:service:region:account-id:resourcetype:resource

Examples:

* Amazon DynamoDB table: `arn:aws:dynamodb:us-west-2:558892968354:table/accounts`
* Amazon S3 bucket: `arn:aws:s3:::survey_bucket/*`
* Amazon SNS topic: `arn:aws:sns:us-west-2:558892968354:EmailSNSTopic`
* SNS topic subscription ID: `arn:aws:sns:us-west-2:558892968354:EmailSNSTopic:3c31c16b-3d53-48a6-ba54-385a06c29a45`

The components of the ARN are:

* Partition: The partition that the resource is in. For standard AWS regions, the partition is `aws`. If you have resources in other partitions, the partition is `aws-[partitionname]`. For example, the partition for resources in the China region is `aws-cn`.
* Service: The service namespace that identifies the AWS product (for example, `s3`, `sns`).
* Region: The region that the resource resides in (for example, `us-west-2`). Some services are global, such as S3. Those services do not require a region specified.
* Account: The ID of the AWS account that owns the resource, without the hyphens, for example, `558892968354`. Note that the ARNs for some resources don't require an account number.
* `Resource`, `resourcetype:resource`, or `resourcetype/resource`: The content of this part of the ARN varies by service, as shown in examples above. Some services allows paths for resource names.

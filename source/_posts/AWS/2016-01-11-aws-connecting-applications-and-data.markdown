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


Example

```
arn:aws:sns:us-west-2:558892968354:EmailSNSTopic
arn:aws:sns:us-west-2:558892968354:OrderSNSTopic
```

### SQS

http://en.clouddesignpattern.org/index.php/CDP:Queuing_Chain_Pattern

### Kinesis

"You can use the Amazon Kinesis Streams API or the Amazon Kinesis Producer Library (KPL) to develop producers."

KPL: Kinesis Producer Library

KCL: Kinesis Consumer Library

Streams like a streaming map-reduce application.

### SWF (Simple Workflow)

#### Additional resources

* https://www.youtube.com/watch?v=lBUQiek8Jqk

### SQS

VisibilityTimeout is a soft locking mechanism.

### SNS

Interesting example: Image Processing system.


### Lab 5

arn:aws:sns:us-west-2:558892968354:EmailSNSTopic

arn:aws:sns:us-west-2:558892968354:OrderSNSTopic


```
You have subscribed your_email@work.com to the topic:
EmailSNSTopic.

Your subscription's id is: 
arn:aws:sns:us-west-2:558892968354:EmailSNSTopic:3c31c16b-3d53-48a6-ba54-385a06c29a45
```

SNS:
http://docs.aws.amazon.com/sns/latest/dg/using-awssdkjava.html

SQS:
https://github.com/aws/aws-sdk-java/blob/master/src/samples/AmazonSimpleQueueService/SimpleQueueServiceSample.java

Converting POJO to JSON:
https://fasterxml.github.io/jackson-databind/javadoc/2.5/com/fasterxml/jackson/databind/ObjectMapper.html

http://www.mkyong.com/java/how-to-convert-java-object-to-from-json-jackson/

```
Subject: Status of pharmaceuticals order.

Your pharmaceutical supplies will be shipped 5 business days from the date of order.

--
If you wish to stop receiving notifications from this topic, please click or visit the link below to unsubscribe:
https://sns.us-west-2.amazonaws.com/unsubscribe.html?SubscriptionArn={TopicARNcode}&Endpoint=myemail@gmail.com
```

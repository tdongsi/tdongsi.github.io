---
layout: post
title: "AWS: Connecting Applications and Data"
date: 2016-01-19 18:37:02 -0800
comments: true
published: false
categories: 
- AWS
---

### [Amazon Resource Name](http://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html)

The Amazon Resource Name (ARN) is used to uniquely identify an AWS resource. You will need to use ARNs to connect your services and data in AWS.

Format:

* arn:partition:service:region:account-id:resource
* arn:partition:service:region:account-id:resourcetype/resource
* arn:partition:service:region:account-id:resourcetype:resource

Examples:

* Amazon DynamoDB table: `arn:aws:dynamodb:us-west-2:558892968354:table/accounts`
* Amazon S3 bucket: `arn:aws:s3:::survey_bucket/*`
* Amazon SNS topic: `arn:aws:sns:us-west-2:558892968354:EmailSNSTopic`

The components of the ARN are:

* Partition: The partition that the resource is in. For standard AWS regions, the partition is `aws`. If you have resources in other partitions, the partition is `aws-[partitionname]`. For example, the partition for resources in the China region is `aws-cn`.
* Service: The service namespace that identifies the AWS product (for example, `s3`, `sns`).
* Region: The region that the resource resides in (for example, `us-west-2`). Some services are global, such as S3. Those services do not require a region specified.
* Account: The ID of the AWS account that owns the resource, without the hyphens, for example, `558892968354`. Note that the ARNs for some resources don't require an account number.
* `Resource`, `resourcetype:resource`, or `resourcetype/resource`: The content of this part of the ARN varies by service, as shown in examples above. Some services allows paths for resource names.

### Services for connecting applications and data

#### SQS

http://en.clouddesignpattern.org/index.php/CDP:Queuing_Chain_Pattern

#### Kinesis

"You can use the Amazon Kinesis Streams API or the Amazon Kinesis Producer Library (KPL) to develop producers."

KPL: Kinesis Producer Library

KCL: Kinesis Consumer Library

Streams like a streaming map-reduce application.

#### SWF (Simple Workflow)

* https://www.youtube.com/watch?v=lBUQiek8Jqk

#### SQS

VisibilityTimeout is a soft locking mechanism.

#### SNS

Interesting example: Image Processing system.

#### Lambda

http://docs.aws.amazon.com/lambda/latest/dg/current-supported-versions.html

#### Example

``` plain
arn:aws:sns:us-west-2:558892968354:EmailSNSTopic
arn:aws:sns:us-west-2:558892968354:OrderSNSTopic
```

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









---
layout: post
title: "AWS: Developing with Amazon S3"
date: 2016-01-18 17:13:28 -0800
comments: true
published: false
categories: 
- AWS
- Java
- Python
---

http://docs.aws.amazon.com/AmazonS3/latest/dev/ListingKeysHierarchy.html

### S3 Buckets and Objects

Files of any kind such as text, video, photo are stored as objects in S3 buckets. 
The bucket name must be globally unique across Amazon S3. It is your responsibility to ensure uniqueness of the bucket name.
A bucket can be *versioning-enabled*, it will store every version of every object in the bucket.

Bucket naming tips:

* To ensure uniqueness, you might prefix the bucket name with the name of your organization.
* Avoid using a period in the bucket name. Buckets that have a period in the bucket name can cause certificate exception when accessing with HTTPS-based URLs.

Each object in S3 is identified by a unique key. The object key is used for upload and retrieval. Alphanumeric characters and `!-_.*'/` are allowed in a key name.

Object key naming tips:

* Use `/` or other delimiters to logically group your objects. For example, `prog/java/arrays.html`. There is no hierarchy of objects or nested buckets in S3.

### Operations on Objects

PUT: upload or copy object, up to 5 GB. You can use multi-part upload API for larger objects up to 5 TB.

GET: Retrieve a whole object or part of an object.

### Lab 2

http://docs.aws.amazon.com/AWSJavaSDK/latest/javadoc/com/amazonaws/services/s3/AmazonS3Client.html

http://docs.aws.amazon.com/AmazonS3/latest/dev/RetrievingObjectUsingJava.html

http://docs.aws.amazon.com/AmazonS3/latest/dev/UploadObjSingleOpJava.html


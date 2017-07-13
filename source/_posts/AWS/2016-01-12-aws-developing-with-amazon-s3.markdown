---
layout: post
title: "AWS: Developing with Amazon S3"
date: 2016-01-18 17:13:28 -0800
comments: true
published: true
categories: 
- AWS
- Java
- Python
---

Amazon Simple Storage Service or S3 is a simple, scalable web services to store and retrieve data. 
This post talks about basic concepts of buckets and objects in S3, basic and advanced operations on objects in S3, and standard development considerations when working with S3 using SDK.

<!--more-->

### S3 Buckets and Objects

Files of any kind such as text, video, photo are stored as objects in S3 *buckets*. 
The bucket name must be globally unique across Amazon S3. It is your responsibility to ensure uniqueness of the bucket name.
A bucket can be *versioning-enabled*, it will store every version of every object in the bucket.

Each *object* in S3 is identified by a unique key. The object key is used for upload and retrieval. Alphanumeric characters and `!-_.*'/` are allowed in a key name.

Bucket naming tips:

* To ensure uniqueness, you might prefix the bucket name with the name of your organization.
* Avoid using a period in the bucket name. Buckets that have a period in the bucket name can cause certificate exception when accessing with HTTPS-based URLs.

Object key naming tips:

* Use prefixes and `/` (or other delimiters) to logically group your objects. For example, `prog/java/arrays.html`. There is no hierarchy of objects (e.g., folder) or nested buckets in S3.
  * However, the Amazon S3 console supports the [folder concept](http://docs.aws.amazon.com/AmazonS3/latest/UG/FolderOperations.html) for convenience and usability. Amazon S3 does this by using key name prefixes for objects.
* For performance and scalability, consider using hash as the outermost prefix, in addition to other logical grouping prefixes. See "Programming Considerations" section below.

### Operations on Objects

Basic operations on S3 objects and buckets are:

* Put: upload or copy object, up to 5 GB. You can use multi-part upload API for larger objects up to 5 TB.
* Get: Retrieve a whole object or part of an object.
* [List Keys](http://docs.aws.amazon.com/AmazonS3/latest/dev/ListingKeysHierarchy.html): List object keys by prefix and delimiter.
* Delete: Delete one or more objects. 
  * If versioning is not enabled, an object is permanently deleted by specifying its key. 
  * If versioning is enabled, you delete an object by specifying a key and version ID. You must delete all versions of an object to remove it.
  * If versioning is enabled and version is not specified, S3 adds a delete marker to current version of the object. Trying to retrieve an object with a delete marker will returns a "404 Not Found" error by S3.
* Restore: Restore an object archived on Amazon Glacier.

#### Other operations in S3

Advanced operations that you should know when situations arise.

**Scenario 1**: You want to let users upload files to your buckets for some time duration. 
**Solution 1**: You should never share your AWS credentials to let users upload files to your buckets. 
Instead, generate a **pre-signed URL** with your security credentials, bucket name, object key, HTTP method (PUT or GET), and expiration date and time. 
You share this pre-signed URL to users who will use this to access your S3 buckets.

**Scenario 2**: Encryption and strict data security is required.
**Solution 2**: You can enable:

* Securing data in transit.
  * SSL-encrypted data transfer by using HTTPS
  * [Client-side encryption](http://docs.aws.amazon.com/AmazonS3/latest/dev/UsingClientSideEncryption.html)
* Securing data at rest on AWS server.
  * [Server-side encryption](http://docs.aws.amazon.com/AmazonS3/latest/dev/serv-side-encryption.html)

**Scenario 3**: You want your web applications that are loaded in one domain to interact with S3 resources in a different domain.
**Solution 3**: Check out [CORS](http://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html).

### Programming considerations

* According to [this guideline](http://docs.aws.amazon.com/AmazonS3/latest/dev/request-rate-perf-considerations.html), **avoid** using some sequential prefix (e.g., timestamp or alphabetical sequence) for your objects' key names. Instead, prefix the key name with its hash and, optionally, store the original key name in the object's metadata. See examples in the link for more information.
* If your application uses fixed buckets, avoid unnecessary requests by checking the existence of buckets. Instead, handle [NoSuchBucket errors](http://docs.aws.amazon.com/AmazonS3/latest/API/ErrorResponses.html) when buckets do not exist.
* Set the object metadata before uploading an object. Otherwise, you will have extra requests to do copy operation to update metadata.
* Cache bucket and key names if possible.
* Set bucket region closest to latency-sensitive users.
* Compress objects to reduce the size of data transferred and storage used.
* Use an exponential back-off algorithm to retry after failed connection attempts. See [here](http://docs.aws.amazon.com/general/latest/gr/api-retries.html).
* Enable application logging. For example, [in Java](http://docs.aws.amazon.com/AWSSdkDocsJava/latest/DeveloperGuide/java-dg-logging.html).
* Enable [server access logging](http://docs.aws.amazon.com/AmazonS3/latest/dev/ServerLogs.html).




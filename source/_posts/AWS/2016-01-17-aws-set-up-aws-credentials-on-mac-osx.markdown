---
layout: post
title: "AWS: Getting started on Mac OSX"
date: 2016-01-17 20:57:35 -0800
comments: true
categories: 
- AWS
- MacOSX
- Java
- Python
---

Quick-start guide on AWS development in Java and Python.

<!--more-->

### Set up AWS development environment

First, you need to set up your AWS credentials on your Mac by creating the following files at the following specific locations:

``` plain
MTVL1288aeea2-82:~ cdongsi$ mkdir ~/.aws
MTVL1288aeea2-82:~ cdongsi$ touch ~/.aws/credentials
MTVL1288aeea2-82:~ cdongsi$ touch ~/.aws/config
```

In Windows, the locations of those files will be `C:\Users\USERNAME\.aws\credentials` and `C:\Users\USERNAME\.aws\config`, respectively.
You *must* fill in your AWS access credentials (Access Key ID and Secret Access Key) into the file `credentials`. Optionally, you can set the default region in the `config` file. 
The content of the files will look like the following: 

``` plain
MTVL1288aeea2-82:~ cdongsi$ cat ~/.aws/credentials
[default]
aws_access_key_id = your_access_key_id
aws_secret_access_key = your_secret_access_key

MTVL1288aeea2-82:~ cdongsi$ cat ~/.aws/config
[default]
region=us-west-2
```

### HelloAws using Java

Now, you can install AWS Toolkit for Eclipse from [this link](http://aws.amazon.com/eclipse/). Follow the instruction in that page to install AWS Toolkit.

After AWS Toolkit is installed, you are ready to run the first `HelloAws` Java application. In Eclipse, create a AWS Console application.

1. Click the new orange button on Eclipse taskbar named "AWS Toolkit for Eclipse".
1. Click the link named "Create a New AWS Java Project".
1. Fill in "Project name" as "HelloAws". Check "AWS Console Application" from "AWS SDK for Java Samples" panel.

Note that the sample generated has the following instruction in its main class. If you haven't do it, follow the steps above to set up your AWS access credentials.

``` java
public class AwsConsoleApp {

    /*
     * Before running the code:
     *      Fill in your AWS access credentials in the provided credentials
     *      file template, and be sure to move the file to the default location
     *      (/Users/cdongsi/.aws/credentials) where the sample code will load the
     *      credentials from.
     *      https://console.aws.amazon.com/iam/home?#security_credential
     *
     * WARNING:
     *      To avoid accidental leakage of your credentials, DO NOT keep
     *      the credentials file in your source directory.
     */

    static AmazonEC2      ec2;
    static AmazonS3       s3;
    static AmazonSimpleDB sdb;
```

If your AWS credentials are ready, simply run the sample AWS console code as "Java Application". The output will look something like this:

``` plain
===========================================
Welcome to the AWS Java SDK!
===========================================
You have access to 4 Availability Zones.
You have 0 Amazon EC2 instance(s) running.
You have 0 Amazon SimpleDB domain(s)containing a total of 0 items.
You have 0 Amazon S3 bucket(s), containing 0 objects with a total size of 0 bytes.
```

### HelloAws using Python

To install [AWS SDK for Python](http://aws.amazon.com/sdk-for-python/), run the following the command as instructed in that page:

```
pip install boto3

```

In my case, I used a slightly different command to avoid permission errors on Mac OSX:

```
pip install boto3 --user
```

I use PyCharm/IntelliJ as IDE for Python and, apparently, there is no Python sample for it. In PyCharm, you can use the following Python script as your `HelloAws` program:

``` python
import boto3
from botocore.exceptions import ClientError,NoCredentialsError
import sys

def getS3BucketNumber():

    try:
        s3 = boto3.resource('s3')
        buckets = []
    except NoCredentialsError:
        print "No AWS Credentials"
        sys.exit()

    try:
        bucket_num = len(list(s3.buckets.all()))
        print "Number of buckets: " + str(bucket_num)
        return bucket_num
    except ClientError as ex:
        print(ex)
        return 0

if __name__ == '__main__':
    getS3BucketNumber()
```

Note that it is based on the [Quick start on Github](https://github.com/boto/boto3#quick-start). In PyCharm, running the above Python should print the following output:

``` plain
Number of buckets: 0
```

### Quick note on Python API vs. Java API

Note that Boto3 SDK for Python support ["Resource API"](http://boto3.readthedocs.org/en/latest/guide/resources.html). 
As opposed to "Service Client API" like AWS SDK for Java, Resource API provides a higher level interface to the service and it is easier to understand and simpler to use.

For example, the generated example for AWS's Java SDK uses a Service Client API. It uses a class AmazonS3Client that controls the requests you make to the S3 service. 
Meanwhile, the Boto3 SDK for Python has classes representing the conceptual resources (e.g., s3.Bucket) that you interact with when using the S3 service. 
This is a higher level abstraction compared to a client class like AmazonS3Client making low-level calls to the service API.

### External Links

* Python
  * [Developer Guide](https://boto3.readthedocs.org/en/latest/guide/index.html)
  * [API Documentation](https://boto3.readthedocs.org/en/latest/reference/core/index.html)
* Java
  * [Developer Guide](http://docs.aws.amazon.com/AWSSdkDocsJava/latest/DeveloperGuide/welcome.html)
  * [API Documentation](http://docs.aws.amazon.com/AWSJavaSDK/latest/javadoc/index.html)
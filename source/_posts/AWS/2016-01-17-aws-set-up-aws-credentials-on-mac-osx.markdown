---
layout: post
title: "AWS: Getting started on Mac OSX"
date: 2016-01-17 20:57:35 -0800
comments: true
categories: 
- AWS
- MacOSX
---

First, you need to set up your AWS credentials on your Mac by creating the following files at the following specific locations:

``` plain
MTVL1288aeea2-82:~ cdongsi$ mkdir ~/.aws
MTVL1288aeea2-82:~ cdongsi$ touch ~/.aws/credentials
MTVL1288aeea2-82:~ cdongsi$ touch ~/.aws/config
```

In Windows, the locations of those files will be `C:\Users\USERNAME\.aws\credentials` and `C:\Users\USERNAME\.aws\config`, respectively.
You *must* fill in your AWS access credentials (Access Key ID and Secret Access Key) into the file `credentials`. Optionally, you can set the default region in the `config` file. The content of the files will look like the following: 

``` plain
MTVL1288aeea2-82:~ cdongsi$ cat ~/.aws/credentials
[default]
aws_access_key_id = your_access_key_id
aws_secret_access_key = your_secret_access_key

MTVL1288aeea2-82:~ cdongsi$ cat ~/.aws/config
[default]
region=us-west-2
```

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

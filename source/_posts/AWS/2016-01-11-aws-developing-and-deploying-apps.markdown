---
layout: post
title: "AWS: Setting up Multi-Factor Authentication (MFA)"
date: 2016-01-22 18:37:23 -0800
comments: true
published: true
categories: 
- AWS
- Security
---

This process is simple and most people should know when developing a serious AWS application. Follow the following steps to enable MFA:

* Launch the AWS Console with your AWS Account. From the AWS Console, select "Identity & Access Management".

{% img center /images/aws/mfa/step1_iam.png Screenshot %}

* Select "Users" tab on the left side.

{% img center /images/aws/mfa/step2_users.png Screenshot %}

* Click on your username from the list of users.

{% img center /images/aws/mfa/step3_you.png Screenshot %}

* Make sure that "Security Credentials" tab is selected. Scrolling down to the bottom, under "Sign-in Credentials" section, select "Manage MFA Device". 

{% img center /images/aws/mfa/step4_signin.png Screenshot %}

* Follow the prompts to set up.



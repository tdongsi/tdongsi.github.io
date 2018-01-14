---
layout: post
title: "AWS: Setting up Multi-Factor Authentication (MFA)"
date: 2016-01-22 18:37:23 -0800
comments: true
published: true
featured: true
categories: 
- AWS
- Security
---

This process is simple and most people should use MFA when developing a serious AWS application. Follow the following steps to enable MFA for AWS.

<!--more-->

* Launch the AWS Console with your AWS Account. From the AWS Console, select "Identity & Access Management".

{% img center /images/aws/mfa/step1_iam.png 350 200 Screenshot %}

* Select "Users" tab on the left side.

{% img center /images/aws/mfa/step2_users.png 447 460 Screenshot %}

* Click on your username from the list of users.

{% img center /images/aws/mfa/step3_you.png 555 256 Screenshot %}

* Make sure that "Security Credentials" tab is selected. Scrolling down to the bottom, under "Sign-in Credentials" section, select "Manage MFA Device". 

{% img center /images/aws/mfa/step4_signin.png 603 314 Screenshot %}

* In the pop-up window, you are allowed to choose a virtual MFA device or a physical MFA device. The most convenient option is a virtual MFA device which only requires you to have a smartphone with some AWS MFA-compatible application. The list of AWS MFA-compatible applications are listed in [here](http://aws.amazon.com/iam/details/mfa/).

{% img center /images/aws/mfa/step5_device.png Screenshot %}

* In my case, I use [Google Authenticator](https://play.google.com/store/apps/details?id=com.google.android.apps.authenticator2&hl=en). After installing the app, simply add an account and select "Scan a barcode".

{% img center /images/aws/mfa/step6_app.png 300 258 Screenshot %}

* Follow the prompts on AWS MFA webpages to arrive at the following page with QR code. You will then enter the first 6 digit PIN from Google Authenticator into Code 1 box. Wait for it to change and then add the second code into Code 2 box.

{% img center /images/aws/mfa/step7_setup.png 495 444 Screenshot %}

* You are now all set for MFA. All future accesss will require you to enter the MFA code from the Google Authenticator on your Android/iPhone during login.

{% img center /images/aws/mfa/step8_mfa.png 300 185 Screenshot %}


---
layout: post
title: "Automated downloading BART parking permits"
date: 2016-10-30 17:12:31 -0700
comments: true
categories: 
- Python
- Automation
---

### Problem

I have been commuting to San Francisco using [BART](http://www.bart.gov/).
For BART commutes, before having the Monthly Parking Permit, you usually have no choice but using Daily Parking Permits for car parking.
You will often end up having to download multiple PDF files for the daily permits and print them to put on your vehicle's dashboard.
The [BART reservation website](https://www.select-a-spot.com/bart/) offers no easy way to download all of them in one click (see the screenshot).

![BART Screenshot](https://github.com/tdongsi/bart-parking/blob/develop/BART.jpg?raw=true "Screenshot")

Personally, the BART commute itself is not that bad, especially when I usually find a seat. 
But it is really painful to download every ... single ... PDF ... permit manually before printing them.

### Solution

I wrote [some Python scripts](https://github.com/tdongsi/bart-parking) to automate the process of downloading every single permits.
Simply run the `main.py` script and input your username and password, as shown below.

```
C:\Github\bart-parking\bart>python main.py
bart-view   : INFO     Please input your username and password.
Username:YOUR_USERNAME
Password:
bart-view   : INFO     Done reading username and password
requests.packages.urllib3.connectionpool: INFO     Starting new HTTPS connection (1): www.select-a-spot.com
bart        : INFO     Login Response: https://www.select-a-spot.com/bart/users/login/ 302
bart        : INFO     Created folder to save permit PDF files.
bart        : INFO     Finished downloading permit 1183167.
bart        : INFO     Finished downloading permit 1183161.
bart        : INFO     Finished downloading permit 1183136.
bart        : INFO     Finished downloading permit 1180762.
bart        : INFO     Finished downloading permit 1177938.
bart        : INFO     Finished downloading permit 1177937.
bart        : INFO     Finished downloading permit 1177935.
bart        : INFO     Finished downloading permit 1177929.

C:\Github\bart-parking\bart>
```
### External links

* [Github repo](https://github.com/tdongsi/bart-parking)

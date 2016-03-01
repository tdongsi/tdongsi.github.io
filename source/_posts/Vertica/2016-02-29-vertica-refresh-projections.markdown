---
layout: post
title: "Vertica: Refresh your projections"
date: 2016-02-29 00:54:02 -0800
comments: true
categories:
- Vertica
---

```
select START_REFRESH();
```


https://community.dev.hpe.com/t5/Vertica-Knowledge-Base/Understanding-Vertica-Epochs/ta-p/233749

The epoch advances when the logical state of the system changes or when the data is committed with a DML operation (INSERT, UPDATE, MERGE, COPY, or DELETE). The EPOCHS system table contains the date and time of each closed epoch and the corresponding epoch number of the closed epoch.

AHM didn't advance because of un refreshed projections listed below 
 
 
 
Ancient History Mark Does NotAdvance
There are times that the ancient history marker does not advance. The AHM does not advance in the following scenarios:
·         If there is an unrefreshed projection. To resolve this, export the DDL and refresh the projection. To find about the unrefreshed projection, use the following command:
=> SELECT * FROM projections where is_up_to_date = 'f';
 
If the projection to be refreshed is a large table. Try the workaround described in the Best Practices for Refreshing Large Projections This workaround makes sure that Vertica does not hold the AHM until the refresh projection operation finishes.

https://community.dev.hpe.com/t5/Vertica-Blog/Best-Practices-for-Refreshing-Large-Projections/ba-p/229505


Going back to the AHM “issue” mentioned here, this is not a reason for panic if AHM is behind the current time. This is normal in the functionality of Vertica. For anybody who still have doubts about AHM is, bellow is the explanation from Vertica:
 
AHM
An abbreviation for Ancient History Mark, AHM is the epoch prior to which historical data can be purged from physical storage.

It was already mentioned in the thread that AHM will not advance if there’s any projection not up to date. Also it will not advance if there’s no activity (data insert/update or delete).
What AHM controls is purging old/historical data.
Although it’s true that deleted data from a table affects the performance of the queries using that table, AHM doesn’t globally influence performance. The only thing that it can influence is not letting you purge the data for a particular table if the epoch is beyond the epoch for the deleted data on that table.
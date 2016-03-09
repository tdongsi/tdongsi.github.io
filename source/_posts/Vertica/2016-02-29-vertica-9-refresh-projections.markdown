---
layout: post
title: "Vertica: Refresh your projections"
date: 2016-02-29 00:54:02 -0800
comments: true
categories:
- Vertica
---

Most information presented in this post is directly quoted from [this page](https://community.dev.hpe.com/t5/Vertica-Knowledge-Base/Understanding-Vertica-Epochs/ta-p/233749).

**Epoch**: An epoch is 64-bit number that represents a logical time stamp for the data in Vertica.
The epoch advances when the logical state of the system changes or when the data is committed with a DML operation (INSERT, UPDATE, MERGE, COPY, or DELETE). 
The `EPOCHS` system table contains the date and time of each closed epoch and the corresponding epoch number of the closed epoch.

``` plain epochs table
=> select * from epochs;

epoch_close_time	          epoch_number
2016-03-04 21:44:24.192495	610131
```

**Ancient History Mark (AHM)**: A large epoch map can increase the catalog size. 
The ancient history mark is the epoch prior to which historical data can be purged from physical storage. 
You cannot run any historical queries prior to the AHM.
By default, Vertica advances the AHM at an interval of 5 minutes.

There are scenarios that the ancient history marker does not advance: there is an unrefreshed [projection](/blog/2016/02/07/vertica-7-projections/). 
To find about the unrefreshed projection, use the following command:

``` plain
SELECT * FROM projections where is_up_to_date = 'f';
```

It was already mentioned in the HPE page that AHM will not advance if there’s any projection not up to date. 
However, it also means that AHM will also not advance if there’s no activity (data insert/update or delete) on a table.
AHM could lag behind at the create epoch of some unrefreshed projection.
Therefore, we need to make sure we are **always** refreshing projections after creating them.

Generally, you can refresh a projection by executing the `START_REFRESH` meta-function, which is a background process, or the `REFRESH` meta-function, which is a foreground process.

``` plain
select START_REFRESH();
```

### Links

1. [Epoch and AHM](https://community.dev.hpe.com/t5/Vertica-Knowledge-Base/Understanding-Vertica-Epochs/ta-p/233749)
1. [Best Practices](https://community.dev.hpe.com/t5/Vertica-Blog/Best-Practices-for-Refreshing-Large-Projections/ba-p/229505)

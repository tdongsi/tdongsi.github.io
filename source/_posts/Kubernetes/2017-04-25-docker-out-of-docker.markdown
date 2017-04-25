---
layout: post
title: "Docker out of Docker"
date: 2017-04-25 10:42:04 -0700
comments: true
categories: 
- Docker
- Kubernetes
- Jenkins
---

### `groupadd` examples

The following example creates a new group called apache

```
$ groupadd apache
```

Make sure it is created successfully.

```
# grep apache /etc/group
apache:x:1004:
```
2. Create new group with a specific groupid

If you don’t specify a groupid, Linux will assign one automatically.

If you want to create a group with a specific group id, do the following.

# groupadd apache -g 9090

# grep 9090 /etc/group
apache:x:9090:

### References

* [groupadd](http://linux.101hacks.com/unix/groupadd/)
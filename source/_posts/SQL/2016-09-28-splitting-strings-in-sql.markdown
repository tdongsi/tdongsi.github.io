---
layout: post
title: "Splitting strings in Vertica SQL"
date: 2016-09-28 23:23:45 -0700
comments: true
published: false
categories: 
- SQL
- Vertica
---

In Python and Java, splitting strings is straight forward

``` plain
// Python
"example string here".split()

// Java: using Guava's Splitter

```

It is not so straight-forward for splitting strings, including but not limited to comma-separated strings.
As shown in [the last post](/blog/2016/08/17/analytic-functions-in-mysql/), not all SQL dialects are equal.
Different database systems have different ways of doing so in SQL, as shown in the following links (1, 2)

http://stackoverflow.com/questions/2647/how-do-i-split-a-string-so-i-can-access-item-x

http://stackoverflow.com/questions/10581772/how-to-split-a-comma-separated-value-to-columns

This post will throws another into that mess.

``` sql Spitting comma-separated strings
SELECT
label_key,
SPLIT_PART(labels, ',', row_num) AS Label
FROM
(SELECT ROW_NUMBER() OVER () AS row_num FROM tables) row_nums
JOIN label_map i
WHERE SPLIT_PART(labels, ',', row_num) <> '';
```


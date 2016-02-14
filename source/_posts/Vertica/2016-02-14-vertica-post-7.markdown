---
layout: post
title: "Vertica projections"
date: 2016-02-07 00:50:44 -0800
comments: true
categories: 
- Vertica
- Performance
---

Projections are key in Vertica performance tuning. 
Details of Vertica projections are discussed in the following blog posts from HP-Vertica:

1. https://www.vertica.com/2011/09/01/the-power-of-projections-part-1/
2. https://www.vertica.com/2011/09/02/the-power-of-projections-part-2/
3. https://www.vertica.com/2011/09/06/the-power-of-projections-part-3/

In summary, Vertica projections represent collections of columns (like table) but they are optimized for analytics at the physical storage structure level and they are not constrained by the logical schema.
For each regular table, Vertica requires a minimum of one projection, called a “superprojection”. 
Vertica creates a default super-projection when running CREATE TABLE statement.
[Part 3](https://www.vertica.com/2011/09/06/the-power-of-projections-part-3/) also compares Vertica projections with "Materialized Views" and "Indexes" in traditional databases.

For Vertica performance tuning, we create multiple projections, customize them and parameters of each projection to achieve the best performance.
Database Designer is a tool provided by Vertica to help us find the optimal projections, based on data statistics and frequent queries.



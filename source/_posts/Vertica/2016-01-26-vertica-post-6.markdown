---
layout: post
title: "Vertica: Performance Optimization Notes"
date: 2016-02-13 23:52:44 -0800
comments: true
published: true
categories: 
- Vertica
- Performance
---

In this blog post, I will list some bad SQL examples that give worse performance in Vertica and the recommended practices/workarounds for each case.
Most of these optimization notes are learnt through interaction with [Nexius](http://www.nexius.com/software-and-business-intelligence/) consultants.

### `NOT IN` is better than `NOT EXISTS`

When we want to insert a row into a dimension table AND check for duplicates at the same time, we usually do this in DML scripts:

``` sql BAD
SELECT 'United States', 'English' 
WHERE NOT EXISTS (SELECT 'x' FROM dim_country WHERE country_name = 'United States')
```

However, for all such inserts, we were recently informed that it is better **in Vertica** to do `NOT IN` instead of `NOT EXISTS`.
So, for example above:

``` sql GOOD
SELECT 'United States', 'English' 
WHERE 'United States' NOT IN (select country_name from dim_country)
```

### Avoid using `LEFT JOIN` to check existence

Let's say you have an ETL that regularly inserts new data into an existing dimension table.  

``` sql BAD
INSERT INTO dim_country                    
(
    country_id,
    country_name,
    country_language,
) 
SELECT ssp.country_id,
    ssp.country_name,
    ssp.country_language,
FROM staging_table ssp
LEFT JOIN dim_country dc on dc.country_id=ssp.country_id
WHERE dc.country_id is NULL;
```

We are sometimes doing `LEFT JOIN` like this only to determine whether or not an entry already exists in the table. 
It would be faster to instead use a `WHERE` clause to check if an entry exists. 
Although it might sound counter-intuitive, but reducing `JOIN` operations like this has been regularly recommended.

``` sql GOOD
INSERT INTO dim_country                    
(
    country_id,
    country_name,
    country_language,
) 
SELECT ssp.country_id,
    ssp.country_name,
    ssp.country_language,
FROM staging_table ssp
WHERE ssp.country_id NOT IN (SELECT country_id FROM dim_country);
```

### Avoid calling functions in `WHERE` and `JOIN` clauses

For this performance tip, we make a slight change the ETL example in the last section above where `country_id` column is removed. In this case, we can use a normalized `country_name` as the ID to check for existing entries in the table:

``` sql BAD
INSERT INTO dim_country                    
(
    country_name,
    country_language,
) SELECT ssp.country_name,
    ssp.country_language,
FROM staging_table ssp
LEFT JOIN dim_country dc on lower(dc.country_name)=lower(ssp.country_name)
WHERE dc.country_name is NULL;
```

In this example, we normalize `country_name` to lower case. Note that `WHERE` clause should be used instead of `LEFT JOIN` as discussed above. 

``` sql BETTER, but still BAD
INSERT INTO dim_country                    
(
    country_name,
    country_language,
) SELECT ssp.country_name,
    ssp.country_language,
FROM staging_table ssp
WHERE lower(ssp.country_name) NOT IN (SELECT lower(country_name) FROM dim_country);;
```
 
However, such change still has bad performance because, in general, function calls in `WHERE` and `JOIN` clauses should be avoided in Vertica. 
In both examples above, calling functions like `LOWER` in `WHERE` and `JOIN` clauses will affect the performance of the ETLs.

The solution for the above example is that since we control what goes into dimension tables, we can ensure that columns like `country_name` are always stored in lower-case. 
Then, we can do the same when creating the temporary table such as `staging_table` that we are comparing to to check for existance.

### Creating temporary tables using SELECT

General comment based on feedback from Nexius on other ETL scripts - when creating temporary tables using SELECT, they recommend creating the temporary table first without a projection, create a super projection with the correct column encodings and ORDER BY clause, and then populate it using INSERT INTO...SELECT FROM. That being said, I understand these are small tables, so this comment may not apply, but I at least wanted to point out this pattern that has been recommended. This applies to all temporary tables created in these scripts - I did not want to repeat it multiple times. If you want to see examples of such code, Ravi is in the process of modifying sbg_datasets/qbo/sql/qbo_company_etl.sql to do this


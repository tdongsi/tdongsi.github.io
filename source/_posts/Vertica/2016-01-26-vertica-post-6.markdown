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

Most of these optimization notes are learnt through interaction with [Nexius](http://www.nexius.com/software-and-business-intelligence/) consultants.

### `NOT IN` is better than `NOT EXISTS`

When we want to insert a row into a dimension table AND check for duplicates at the same time, we usually do this in DML scripts:

``` sql DON'T
SELECT 'United States', 'English' 
WHERE NOT EXISTS (SELECT 'x' FROM dim_country WHERE country_name = 'United States')
```

However, for all such inserts, we were recently informed that it is better **in Vertica** to do `NOT IN` instead of `NOT EXISTS`.
So, for example above:

``` sql DO
SELECT 'United States', 'English' 
WHERE 'United States' NOT IN (select country_name from dim_country)
```

### Avoid using `LEFT JOIN` to check existence

Let's say you have an ETL that regularly inserts new data into an existing dimension table.  

``` sql DON'T
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

We are sometimes doing this `LEFT JOIN` only to determine whether or not an entry already exists in the table. 
It would be faster to instead use a `WHERE` clause such as "WHERE ssp.country_id NOT IN (SELECT country_id FROM dim_country)". 
Although it might sound counter-intuitive, but reducing `LEFT JOIN` operations like this has been regularly recommended.

``` sql DO
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

### Avoid functions in `WHERE` and `JOIN` clauses

``` sql DON'T
INSERT INTO 
    dim_country                    
    (
        country_name,
        country_language,
    ) SELECT ssp.country_name,
        ssp.country_language,
        FROM staging_table ssp
        LEFT JOIN dim_country dc on lower(dc.country_name)=lower(ssp.country_name)
        WHERE dc.country_name is NULL;
```

Note that `WHERE` clause should be used instead of `LEFT JOIN` as discussed above. Another thing I should 

Try to avoid using `LOWER` function in WHERE and JOIN clauses - it affects performance. Since you control what goes into the DIM tables, you can ensure that these columns are always stored in lowercase, and do the same when creating the temporary table that you are comparing to.

### Creating temporary tables using SELECT

General comment based on feedback from Nexius on other ETL scripts - when creating temporary tables using SELECT, they recommend creating the temporary table first without a projection, create a super projection with the correct column encodings and ORDER BY clause, and then populate it using INSERT INTO...SELECT FROM. That being said, I understand these are small tables, so this comment may not apply, but I at least wanted to point out this pattern that has been recommended. This applies to all temporary tables created in these scripts - I did not want to repeat it multiple times. If you want to see examples of such code, Ravi is in the process of modifying sbg_datasets/qbo/sql/qbo_company_etl.sql to do this


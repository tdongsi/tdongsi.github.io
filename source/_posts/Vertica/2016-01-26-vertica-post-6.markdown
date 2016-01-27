---
layout: post
title: "Vertica: Performance Optimization Notes"
date: 2016-01-26 23:52:44 -0800
comments: true
published: false
categories: 
- Vertica
- Performance
---

### `NOT IN` better than `NOT EXISTS`

``` sql DON'T
SELECT 'E2E', 'Pre_production' WHERE NOT EXISTS (SELECT 'x' FROM dim_environment WHERE environment_desc = 'E2E')
```

For all such inserts, we have been told by Nexius that its better in Vertica to do NOT IN instead of NOT EXISTS. So for example:

``` sql DO
SELECT ... WHERE 'E2E' NOT IN (select environment_desc from dim_environment)
```

```
> +        ssp.employee_organization_level,
> +        bf.intuit_function_key,
> +        bt.intuit_business_title_key,
> +        ssp.report_to_level_1,
> +        ssp.report_to_level_2,
> +        ssp.report_to_level_3,
> +        ssp.report_to_level_4,
> +        ssp.report_to_level_5,
> +        ssp.report_to_level_6,
> +        ssp.report_to_level_7,
> +        ssp.report_to_level_8,
> +        ssp.report_to_level_9
> +        FROM stgetl_stg_people ssp 
> +        JOIN dim_intuit_business_title bt ON ssp.business_title=bt.intuit_business_title_desc
> +        JOIN dim_intuit_function bf ON isnull(ssp.function_type,'Not Defined')=bf.intuit_function_desc 
> +        LEFT JOIN dim_intuit_employee die on die.employee_email=ssp.email_id 
```

It seems you are doing this left join only to determine whether or not the employee already exists. It would be faster to instead use a WHERE clause such as WHERE ssp.email_id not in (select employee_email from dim_intuit_employee). I know it sounds counter-intuitive, but this is what Nexius has been recommending

### Avoid functions in WHERE and JOIN clauses

Same comment as before - try to avoid using LOWER function in WHERE and JOIN clauses - it affects performance. Since you control what goes into the DIM tables, you can ensure that these columns are always stored in lowercase, and do the same when creating the temporary table that you are comparing to.

### Creating temporary tables using SELECT

General comment based on feedback from Nexius on other ETL scripts - when creating temporary tables using SELECT, they recommend creating the temporary table first without a projection, create a super projection with the correct column encodings and ORDER BY clause, and then populate it using INSERT INTO...SELECT FROM. That being said, I understand these are small tables, so this comment may not apply, but I at least wanted to point out this pattern that has been recommended. This applies to all temporary tables created in these scripts - I did not want to repeat it multiple times. If you want to see examples of such code, Ravi is in the process of modifying sbg_datasets/qbo/sql/qbo_company_etl.sql to do this


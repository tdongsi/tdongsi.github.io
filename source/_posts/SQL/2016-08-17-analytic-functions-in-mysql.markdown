---
layout: post
title: "Analytic functions in MySQL"
date: 2016-08-17 23:12:54 -0700
comments: true
categories: 
- SQL
- Vertica
- MySQL
---

MySQL has traditionally lagged behind in support for the SQL standard.
However, from my experience, MySQL is often used as the sandbox for SQL code challenges and interviews.
If you are used to work with [Vertica SQL](https://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/SQLReferenceManual/SQLReferenceManual.htm), writing SQL statements in MySQL can be challenging exercises, NOT necessarily in a good way.

### WITH clause

As discussed in this [blog post](/blog/2016/02/03/vertica-6-with-clause/), `WITH` clause syntax, also known as *Common Table Expressions* (CTE), is thankfully supported in Vertica.
In summary, `WITH` clause allows us to arrange sub-queries, usually intermediate steps, in a complex SQL query in sequential, logical order.
This will make the complex queries easier to compose and read: we can write steps by steps of the query from top to bottom like a story (i.e., [literate programming](https://en.wikipedia.org/wiki/Literate_programming)).
Unfortunately, `WITH` clause is not supported by MySQL although this feature has been requested since [2006](https://bugs.mysql.com/bug.php?id=16244).
There are [work-around](http://guilhembichot.blogspot.fr/2013/11/with-recursive-and-mysql.html) for MySQL's lack of CTE, but the easiest way is probably to revert back to using nested subqueries.

Personally, lack of `WITH` clause support in MySQL is my greatest hindrance as I often ended up writing queries using `WITH` clauses as first draft before rewriting those queries using nested subqueries.
This might look really clumsy in SQL interviews even though writing SQL codes with CTE instead of subqueries is the recommended practice.

### Analytical functions

Another regrettable hindrance when working in MySQL is its lack of analytical functions such as `ROW_NUMBER`, `RANK` and `DENSE_RANK`.
Those [analytical functions](https://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/SQLReferenceManual/Functions/Analytic/AnalyticFunctions.htm) are supported in Vertica.
The difference between these three functions can be a bit subtle, and would be best described in the following example:

``` sql Example of ROW_NUMBER, RANK, and DENSE_RANK functions
SELECT customer_name, SUM(annual_income),
ROW_NUMBER () OVER (ORDER BY TO_CHAR(SUM(annual_income),'100000') DESC) row_number, 
RANK () OVER (ORDER BY TO_CHAR(SUM(annual_income),'100000') DESC) rank, 
DENSE_RANK () OVER (ORDER BY TO_CHAR(SUM(annual_income),'100000') DESC) dense_rank 
FROM customer_dimension
GROUP BY customer_name
LIMIT 15;
```
The output of these function is only different if there are duplicates in `SUM(annual_income)` value, as seen in rows 75-81 in the example output belows:

<table border="1"><tr BGCOLOR="#CCCCFF"><th>customer_name</th><th>SUM</th><th>row_number</th><th>rank</th><th>dense_rank</th></tr>
<tr><td>Theodore R. King</td><td>97444</td><td>71</td><td>71</td><td>71</td></tr>
<tr><td>Laura Y. Pavlov</td><td>97417</td><td>72</td><td>72</td><td>72</td></tr>
<tr><td>Carla . Garcia</td><td>97371</td><td>73</td><td>73</td><td>73</td></tr>
<tr><td>Jack Z. Miller</td><td>97356</td><td>74</td><td>74</td><td>74</td></tr>
<tr><td>Steve W. Williams</td><td>97343</td><td>75</td><td>75</td><td>75</td></tr>
<tr><td>Lauren Y. Rodriguez</td><td>97343</td><td>76</td><td>75</td><td>75</td></tr>
<tr><td>Lucas . Webber</td><td>97318</td><td>77</td><td>77</td><td>76</td></tr>
<tr><td>Sarah N. Moore</td><td>97243</td><td>78</td><td>78</td><td>77</td></tr>
<tr><td>Lucas O. Li</td><td>97184</td><td>79</td><td>79</td><td>78</td></tr>
<tr><td>Doug K. Reyes</td><td>97166</td><td>80</td><td>80</td><td>79</td></tr>
<tr><td>Michael . Weaver</td><td>97162</td><td>81</td><td>81</td><td>80</td></tr>
</table>
<br/>


Sadly, these useful analytical functions are not supported in MySQL.
Fortunately, MySQL supports user variables in SQL queries and we can reproduce those functionalities in MySQL using variables and subqueries as follows:

``` sql ROW_NUMBER, RANK, and DENSE_RANK functions in MySQL
-- In Vertica
SELECT 
ROW_NUMBER () OVER (PARTITION BY col_1, col_2 ORDER BY col_3 DESC) AS row_number,
RANK () OVER (PARTITION BY col_1, col_2 ORDER BY col_3 DESC) AS rank,
DENSE_RANK () OVER (PARTITION BY col_1, col_2 ORDER BY col_3 DESC) AS dense_rank,
t.* 
FROM table_1 t

-- In MySQL
SELECT
@row_num:=IF(@prev_col_1=t.col_1 AND @prev_col_2=t.col_2, @row_num+1, 1) AS row_number,
@rank:=IF(@prev_col_1=t.col_1 AND @prev_col_2=t.col_2 AND @prev_col_3=col_3, @rank, @row_num) AS rank,
@dense:=IF(@prev_col_1=t.col_1 AND @prev_col_2=t.col_2, IF(@prev_col_3=col_3, @dense, @dense+1), 1) AS dense_rank,
@prev_col_1 = t.col_1,
@prev_col_2 = t.col_2,
@prev_col_3 = t.col_3,
t.*
FROM (SELECT * FROM table_1 ORDER BY col_1, col_2, col_3 DESC) t,
     (SELECT @row_num:=1, @dense:=1, @rank:=1, @prev_col_1:=NULL, @prev_col_2:=NULL, @prev_col_3:=NULL) var
```

The MySQL work-around is intentionally generic so that I can adapt it to any use case.
In addition, it intentionally has a single pass (no `SET` statements, temporary table) since most SQL code challenges expect a single query.
Finally, note that the above MySQL solution is intentionally incomplete to make it less convoluted.
You need to put that solution in a subquery and `SELECT` only relevant columns from it.

As an example, the above code template is used to solve [this Rank Scores probblem](https://leetcode.com/problems/rank-scores/).
In summary, the question asks for `DENSE_RANK` functionality to be applied on Score column.

``` plain Input table
+----+-------+
| Id | Score |
+----+-------+
| 1  | 3.50  |
| 2  | 3.65  |
| 3  | 4.00  |
| 4  | 3.85  |
| 5  | 4.00  |
| 6  | 3.65  |
+----+-------+
```

``` plain Expected output
+-------+------+
| Score | Rank |
+-------+------+
| 4.00  | 1    |
| 4.00  | 1    |
| 3.85  | 2    |
| 3.65  | 3    |
| 3.65  | 3    |
| 3.50  | 4    |
+-------+------+
```

The solution in Vertica SQL would be straight-forward as follows:

``` sql Solution in Vertica SQL
select Score,
DENSE_RANK() OVER (ORDER BY Score DESC) AS Rank
FROM Scores;
```

In MySQL, apply the above code template and note that there is no `partition clause` to arrive at the following solution:

``` sql Solution in MySQL
SELECT Score, Rank FROM
( SELECT t.Score,
@dense:=IF(@prev_col2=t.Score, @dense, @dense+1) AS Rank,
@prev_col2:=t.Score
FROM (SELECT Score FROM Scores ORDER BY Score DESC) t, 
(SELECT @dense:=0, @prev_col2:=NULL) var ) x
```



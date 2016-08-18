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

Another regrettable hindrance when working in MySQL is its lack of analytical functions such as `row_number`, `rank` and `dense_rank`.
Those [analytical functions](https://my.vertica.com/docs/7.1.x/HTML/index.htm#Authoring/SQLReferenceManual/Functions/Analytic/AnalyticFunctions.htm) are supported in Vertica.
The difference between these three functions can be a bit subtle, and would be best described in the following example:

``` sql Example of row_number, rank, and dense_rank functions
SELECT customer_name, SUM(annual_income),
ROW_NUMBER () OVER (ORDER BY TO_CHAR(SUM(annual_income),'100000') DESC) row_number, 
RANK () OVER (ORDER BY TO_CHAR(SUM(annual_income),'100000') DESC) rank, 
DENSE_RANK () OVER (ORDER BY TO_CHAR(SUM(annual_income),'100000') DESC) dense_rank 
FROM customer_dimension
GROUP BY customer_name
LIMIT 15;
```
The output of these function is only different if there are duplicates in `SUM` value, as seen in rows 75-81 in the example output belows:

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


Unfortunately, these useful analytical functions are not supported in MySQL.


---
layout: post
title: "Functional testing for Data Marts"
date: 2016-03-16 23:18:33 -0700
comments: true
published: true
categories: 
- Vertica
- Testing
- SQL
- Automation
---

In this blog post, I will go over on different approaches over time to verify if a data mart or data warehouse is implemented correctly, and pros and cons associated with each approach.

### Level 0: Manual testing

* **Pros**:
  1. Easy to get started.
* **Cons**:
  1. Time consuming for many tests with multiple runs.
  1. Not repeatable.

Early on in Big Data projects, there was not much automation.
Big Data projects are much different from typical software projects: most of the code complexity (and bugs) lies in Extract-Transform-Load (ETL) processes, typically implemented as a number of SQL scripts.
There are not many tools available for automated testing of SQL scripts, especially for Vertica.

At the beginning, quality engineers and data analysts tested Data Marts by using a number of SQL queries as test queries.
Data analysts are *de facto* end-users and main testers and many of those test queries are based on their experience.

{% img center /images/sql/SQuirreL.png Manual testing %}

We used some SQL clients such as SQuirreL as shown above, connected to Vertica using some JDBC driver, ran the test queries and verified that the outputs match our expectations.
This process is pretty much manual. If an ETL is updated `n` times, we have to repeat this `n` times.
Most of the test queries can only tests the **end results** of ETL processes, where data analysts have domain knowledge on: they know what numbers from those final views or tables should look like.
If there are multiple steps (multiple SQL scripts) in those ETL processes, the intermediate tables are not really accessible to data analysts.
Sometimes, some of these tests are pretty heuristic and arbitrary: e.g., this number of products sold in some channel is "unusually" high today, which "seems" to indicate that ETL went wrong in some intermediate step.

<!--
Functions is not common. 
-->

### Level 1: TestNG

* **Pros**:
  1. Automated, repeatable. Run multiple times with minimal additional effort.
* **Cons**:
  1. Java and SQL codes are cluttered together.
  1. Hard to read, hard to maintain.

After some rounds of manual testing, we started looking into automating the process.
Similar to manual testing, the test cases should be in SQL, to be executed against the data marts for validation. 
The only difference is that it is up to the QEs to organize and automate the execution of those SQL test queries. 
Since the test queries can be sent over a JDBC client like SQuirreL, we can do those programmatically as TestNG test cases.
The test SQL queries, defined as Java strings in TestNG test cases, are sent to the data marts through their respective JDBC interface for execution. 


``` java Test query as constant Java string
public static final int DIM_REGION_COUNT = 245;

@Test(enabled = true)
public void validate_dim_region() {
        // First test query
        String query = "select count(*) from dim_region";
        int output = getJdbcConnection().executeQuery(query);
        Assert.assertTrue(output == DIM_REGION_COUNT, "dim_region count:");
        
        // Second test query
}
```

Here, the test queries are defined as constant strings in Java. 
Note that the test query above is intended to be simple to illustate the automation. 
The actual test queries are usually more complex than that.
The results will be captured in JUnit/TestNG tests, and expectations are verified by using various TestNG assertions.
We also remove heuristic tests that cannot be verified using assertions.
Instead, those tests will be verified during User-Acceptance Test phase where data analysts will try out the final views of data marts.
In addition, we add tests to verify intermediate steps of the ETL processes.

The problem of this approach is that the SQL tests are heavily cluttered by Java codes.
This problem is getting worse when the test queries are usually more complex that they cannot fit into single lines, such as one shown below.
When the number of SQL tests grows larger, it is hard to keep track of all SQL test queries in Java source files.

``` java A complex SQL query as Java string
		String query = "WITH Total_Traffic AS\n" + 
				"(\n" + 
				"    SELECT temp.* from temp as clickstream_data\n" + 
				"    where filter_key = 1\n" + 
				")\n" + 
				", Rock_Music as\n" + 
				"(\n" + 
				"    select * from Total_Traffic\n" + 
				"    WHERE lower(evar28) LIKE 'rock_mus%'\n" + 
				")\n" + 
				", Instrumental_Music as\n" + 
				"(\n" + 
				"    select * from Total\n" + 
				"    WHERE evar28 LIKE '%[ins_mus]%'\n" + 
				")\n" + 
				", Defined_Traffic as\n" + 
				"(\n" + 
				"    select * from Rock_Music\n" + 
				"    UNION\n" + 
				"    select * from Instrumental_Music\n" + 
				")\n" + 
				"select traffic_date_key\n" + 
				", count(distinct visitor_id) as unique_visitor\n" + 
				"from Defined_Traffic\n" + 
				"group by traffic_date_key";
```

### Level 2: Properties files

* **Pros**:
  1. Automated, repeatable. Run multiple times with minimal additional effort.
  1. It is easier to manage SQL test queries. Each test has a name.
* **Cons**:
  1. Test queries and their assertions (expected ouputs) are not paired. Hard to look up and update expected outputs.
  1. All queries have to be in a single line. Hard to read for long test queries.

For the next step, we tried to resolve the problem of Java and SQL codes mixed together.
In this approach, SQL tests and Java codes are partitioned, with SQL queries are contained in `.properties` files, separate from supporting Java codes in `.java` files. 
The SQL test queries will be read by TestNG test cases, using key strings, before sending to database for execution.
The same example above, when organized in this approach, will be as follows:

``` java Test query in properties file
public static final int DIM_REGION_COUNT = 245;
public static final String TEST_QUERY_RESOURCE = "test_queries.properties";

@Test(enabled = true)
public void validate_dim_region() {
        // First test query
        String query = PropertyUtil.getProperty(TEST_QUERY_RESOURCE, "dim_region_count");
        int output = getJdbcConnection().executeQuery(query);
        Assert.assertTrue(output == DIM_REGION_COUNT, "dim_region count:");
        
        // Second test query
        query = PropertyUtil.getProperty(TEST_QUERY_RESOURCE, "dim_region_data");
}
```

``` properties test_queries.properties
dim_region_count=select count(*) from dim_region
dim_region_data=another test query to verify data
```

Using this approach, each test can have a name to express its purpose. 
One can get an overview of the SQL test queries by simply looking at the `properties` file.
The supporting Java code that executes those test queries are abstracted into separate `java` files and can be ignored.

The problems of the above approach are:

(1) SQL test queries are really hard to read in `properties` file.
Each SQL test string must be in a single line. 
Adding white spaces, such as newlines and tabs, for clarity is not possible as it will make the test query truncated and invalid. 
Unfortunately, it is very common that SQL queries are long, with multiple JOIN statements, especially in data mart with [star schema](https://en.wikipedia.org/wiki/Star_schema). 
For hundreds of test cases with complex queries like example below, it is impossible to read in `.properties` file.

``` properties complex_test_queries.properties
complex_query=WITH Total_Traffic AS ( SELECT temp.* from temp as clickstream_data where filter_key = 1), Rock_Music as ( select * from Total_Traffic WHERE lower(evar28) LIKE 'rock_mus%'), Instrumental_Music as (select * from Total WHERE evar28 LIKE '%[ins_mus]%'), Defined_Traffic as (select * from Rock_Music UNION select * from Instrumental_Music) select traffic_date_key, count(distinct visitor_id) as unique_visitor from Defined_Traffic group by traffic_date_key
```

(2) Parts of tests are still in Java (in TestNG assertions), making them hard to maintain and less accessible to data analysts.
From the `properties` file, it is not clear what is the expected output of the SQL queries. 
If there is a test failure, one still has to look it up in Java codes to understand and investigate.
Many data engineers and data analysts may be not familiar with Java and TestNG enough to look for and understand failures in test cases.
It is also worth noting that most of SQL queries are expected to return zero row or integer values like 0. 
For example, a common test query is to find all duplicate records, which is expected to has zero row returned. 
Even those simple assertions have to be encoded using Java and TestNG's library methods.

### Level 3: Script files

* **Pros**:
  1. Automated, repeatable. Run multiple times with minimal additional effort.
  1. It is easier to maintain SQL test queries.
  1. Assertions/Expected outputs are paired with test queries.
  1. Readable by data analysts.
* **Cons**:
  1. Slightly more complex setup to instantiate a SQL Test Runner.
  1. Slightly longer running time.

#### Motivation

In recent Big Data projects, I tried to explore a way to improve readability of SQL tests. 
The main motivation for this "Level 3" is my testing philosophy: **prioritize readability of tests when possible**.

Readable tests are easier to write, automate, and maintain. 
More importantly, ask yourself: If you write a software, you have tests to validate it; if you write a test, how do you validate your test? 
It does not make sense to write tests for tests.
Only by making tests **readable**, you can verify and maintain the tests.

Readable tests also promote collaboration between developers, data analysts and QEs.
Readable tests can be easily shared with developers and data analysts for debugging purposes, especially when they are most comfortable in SQL.
If the tests are readable and accessible to developers, they can easily run the tests on their own, without much intervention from QEs.

#### Implementation

In this approach, I implemented a [test framework](/blog/2016/03/28/sql-unit-test-runner/). The same tests shown in the last sections, using that framework, will look like this:

``` java Test query in test files
private SqlTestRunner testRunner;

@Before
public void setup() {
    testRunner = new SqlTestRunner(getJdbcConnection());
}

@Test(enabled = true)
public void validate_dim_region() throws Exception {
        testRunner.runScript("testscript/dim_region.test");
}
```

``` plain dim_region.test
/* @Test
{
  "name" : "dim_region_count",
  "query" : "select count(*) from dim_region",
  "expected" : "245"
}
*/

/* This is a comment.
Complext test query follows.
*/

/* @Test
{
  "name" : "check_traffic",
  "query" : "WITH Total_Traffic AS
      (
          SELECT temp.* from temp as clickstream_data
          where .... -- filtering
      )
      , Rock_Music as
      (
          select * from Total_Traffic
          WHERE lower(evar28) LIKE 'rock_mus%'
      )
      , Instrumental_Music as
      (
          select * from Total
          WHERE evar28 LIKE '%[ins_mus]%'
      )
      , Defined_Traffic as
      (
          select * from Rock_Music
          UNION
          select * from Instrumental_Music
      )
      select traffic_date_key
      , count(distinct visitor_id) as unique_visitor
      from Defined_Traffic
      group by traffic_date_key",
  "expected" : "2016-03-16 123"
}
*/
```

The file that contains SQL test queries is conventionally named with `.test` extension. 
However, the file can be a text file with any name.
As you can see, the benefits of "Level 2" is retained: the supporting Java code and the actual SQL test queries are partitioned into separate files. 
Each test query has a name (that tells its purpose) associated with it: key string in `.properties` file and value of "name" key in `.test` file.

In addition to those retained benefits, the most obvious benefit of this new approach is that the supporting Java code is minimal since all TestNG assertions have been removed. 
The TestNG assertions, which are ubiquitous in previous "Level 1" and "Level 2" approaches, are no longer present.
Instead, the expected outputs are specified in `.test` file, in the same JSON block with each SQL query. 
The whole TestNG class will only contain code to initialize a connection to database and an instance of [SQL Test Runner](/blog/2016/03/28/sql-unit-test-runner/), all of which is one-time setup. 
As we continue writing functional tests, we can decide to keep all tests in a single `.test` file or group related tests into separate `.test` files. 
If we add more `.test` files, we can just specify the path to the files, in TestNG test cases (i.e., `@Test` functions), as shown in Java code above.

The main advantage of this test framework is readability of those tests, as shown in `.test` file. 
The expected outputs of the SQL queries are specified in the same place, making the tests' intentions more obvious. 
In the example above, the first test query's intention is clearer with assertion in the same location. 
In addition, compared with `.properties` file approach, the SQL query is now easier to read, due to line breaks, as shown in the second example. 

All test automation (in Java) is abstracted from data analysts, and they can read and possibly add tests totally in SQL. 
Big Data projects different from usual software engineering projects is that users, data analysts, know more about the data than typical quality engineers.
Being to able to get their input is essential in ensuring Big Data projects doing the right thing in the right ways.
If they are able to read unit test scripts and confirm the expectations, QEs will save lots of time of translating business requirements to SQL tests.

While it is true that we have additional computational time due to additional layers of abstraction in Java, it is minimal compared to the time to run those queries in databases.
Even then, the additional computational time is totally justified with much better readability. 
Test readability will save (lots of) QE's time, in both developing and maintaining. 
In my opinion, human time is million times more costly than computer time.

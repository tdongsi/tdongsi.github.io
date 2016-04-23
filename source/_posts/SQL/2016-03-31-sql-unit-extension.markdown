---
layout: post
title: "(Pt. 6) Extending SQL Test Runner"
date: 2016-04-16 17:49:34 -0700
comments: true
categories: 
- SQL
- Automation
- Testing
- Vertica
- Java
---

For overview, see [here](/blog/2016/03/16/sql-unit-overview/).

In this post, I will discuss the design of the SQL Test Runner.
From that, I explain how to easily extend the Test Runner to add new capability for new testing needs.
For illustration, I will discuss how I recently added a new functionality to handle a new kind of tests.

### Design of SQL Test Runner

When designing the SQL Test Runner, the following requirements should be taken into account:

1) Test frameworks should be closed to modifications. 
If we have added a few hundred test cases that are running fine in the current test suite, we don't want them to suddenly fail just because a new feature must be added into the test framework.
That could be confusing and counter-productive for anyone who are using it.

2) At the same time, the test framework should be open to extension: ability to add new capability, to address new testing needs.
SQL Unit Testing in ETL context is a pretty new area for us.
Therefore, while the current SQL Unit Test framework appears adequate for most testing now, it must be able to support any new testing needs should they arise.
The test framework should be flexible enough to add new capability for new testing needs for different kinds of ETLs.

These two are also known as [Open/Closed principle](https://en.wikipedia.org/wiki/Open/closed_principle).
Besides that principle, SQL Test Runner codes also use **Template Method** and **Strategy** design patterns.
Knowing these design patterns will make it easier to understand the overall code structure and package organization of SQL Test Runner.



TODO: At the top level, there is BaseRunner.
This parsing is pretty simplistic but it works for most of my testing needs.
For more widespread 


``` java Template Method for running test scripts 
private CodeStrategy codeHandler;
private TestStrategy testHandler;
private JdbcConnection connection;
    
@Override
public final void runScript(String filePath) throws IOException, SQLException {
    SoftAssert sAssert = new SoftAssert();
	
	// Read in the SQL script
	String content = SqlTestUtility.readFile(filePath);
	
	// Remove comments
	String sqlCode = TestBlockUtility.removeComments(content);
	
	Matcher m = TestBlockUtility.testBlockRegex.matcher(sqlCode);
	int startIndex = 0;
	while (m.find()) {
		
		String currentSql = sqlCode.substring(startIndex, m.start());
		if ( currentSql.trim().length() > 0 )
			codeHandler.runSqlCode(currentSql, connection);;
		
		testHandler.runTest( m.group(), connection, sAssert );
		
		startIndex = m.end();
	}
	
	codeHandler.runSqlCode(sqlCode.substring(startIndex), connection );
	sAssert.assertAll();
}
```

### Extending Test Runner

The behaviors of the test runners should NOT be inherited. 
Instead, they should be encapsulated in classes that implement CodeStrategy to handle SQL statements or TestStrategy to handle test blocks `/* @Test {...} */`.
When a new test runner is created to meet new testing needs, we should not subclass the previous test runner.
Instead, we can delegate the old behaviors to the old classes while adding new classes to handle new behaviors or new functionality.
In other words, "composition over inheritance" principle applies here to separate test runner classes and code/test handling that each use.

For example, our current test runner that can run an ETL script in Vertica database using `vsql` command-line tool.
If we need a test runner that is able to run an ETL script in **Netezza** database, we should not modify our *current* test runner. 
It will break the current suite of tests for Vertica.
We should not also subclass the current test runner, in favor of composition.
Instead, we should create a new test runner class with new class extend TestStrategy to handle running ETL in Netezza.

### Example: Extending for data parity checks

#### Background of data parity checks

Recently, I had to do lots of data parity checks to verify changes in Extract-Load processes (i.e., EL with no Transform).
In those data parity checks, we want to make sure data in some columns of two tables (i.e., two projections) must be the same.
In other words, we want to verify if the two following queries return completely matching rows and columns:

``` plain Data parity checks
select col1, col2 from old_table_name

matches
 
select col3, col4 from new_table_name
```

The straight-forward test would be get all rows and columns of those two projections, and perform equality check one by one. 
It would be very time-consuming to write and execute such test cases in Java and TestNG.
Even when the query returns can be managed to be within the memory limit, it is still time-consuming to do data transfer for the two SQL returns, join the columns to prepare for comparison row by row. 
Moreover, note that these expensive operations are carried out on the client side, the test execution machine (e.g., our computer).

The more efficient way for this data parity check is to use these two SQL test queries, using the test blocks shown in [this post](/blog/2016/03/28/sql-unit-test-runner/):

``` plain Test blocks for data parity check
/* @Test
{
    "name" : "parity_check",
    "query" : "select col1, col2 from old_table_name
                EXCEPT
                select col3, col4 from new_table_name
                limit 20",
    "expected" : ""
}
*/

/* @Test
{
    "name" : "parity_check_reverse",
    "query" : "select col3, col4 from new_table_name
                EXCEPT
                select col1, col2 from old_table_name
                limit 20",
    "expected" : ""
}
*/
```

The two SQL test queries is based on the following [set theory identities](https://en.wikipedia.org/wiki/Algebra_of_sets):

<p><span class="math display">\[A = B \Leftrightarrow A \subseteq B \mbox{ and } B \subseteq A\]</span></p>

<p><span class="math display">\[A \subseteq B \Leftrightarrow A \setminus B = \varnothing\]</span></p>

If `Table_A EXCEPT Table_B` returns nothing, it indicates that data in `Table_A` is a subset of data in `Table_B`. Similarly for `Table_B EXCEPT Table_A`. Therefore, if two test cases pass, it means that the data in `Table_A` is equal to the data in `Table_B`.

Using these two queries, we shift most of computing works (`EXCEPT` operations) to the Vertica server side. 
Moreover, in most of the cases when the tests pass, the data transfer would be usually minimal (zero row).
In summary, this will save us lots of computation time (since Vertica server machine is usually much more powerful), data transfer time, and assertion check time.

The `limit 20` clause is also for minimizing data transfer and local computation works.
When the expected return of the test SQL query is nothing (i.e., `"expected" : ""`), we should always add LIMIT clause to the query. 
This will save some test-running time and make your log file cleaner when something went wrong and caused the test to fail.
For example, if there are 100000 additional, erroneous rows of data in `new_table_name` for some reason, the test case "parity_check_reverse" will fail. 
However, instead of transferring 100000 rows, only 20 of those will be sent to the local host (test machine), thanks to the `LIMIT` clauses. 
In addition, the log file of the Test Runner will NOT be flooded with 100000 rows of erroneous data while 20 sample rows are probably enough to investigate what happened.

#### Extending SQL Test Runner

Add new JSON.

Use the old code to handle the old POJOs.

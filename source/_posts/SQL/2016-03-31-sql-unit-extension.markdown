---
layout: post
title: "(Pt. 6) Extending SQL Test Runner"
date: 2016-04-16 17:49:34 -0700
comments: true
published: false
categories: 
- SQL
- Automation
- Testing
- Java
---

Navigation: [Overview](/blog/2016/03/16/sql-unit-overview/), 
[Pt 1](/blog/2016/03/20/sql-unit-functional-tests/), 
[Pt 2](/blog/2016/03/28/sql-unit-test-runner/), 
[Pt 3](/blog/2016/04/10/sql-unit-incremental-data-update/), 
[Pt 4](/blog/2016/04/12/sql-unit-testing/), 
[Pt 5](/blog/2016/04/14/sql-unit-vs-functional/).

In this post, I will discuss the design of the SQL Test Runner.
From that, I explain how to easily extend the Test Runner to add new capability for new testing needs.
In the [next post](http://localhost:4000/blog/2016/04/17/sql-unit-data-parity/), I will give an example on how I added a new functionality to handle a new kind of tests.

### Design Overview of SQL Test Runner

When designing the SQL Test Runner, the following requirements should be taken into account:

1) Test frameworks should be closed to modifications. 
If we have added a few hundred test cases that are running fine in the current test suite, we don't want them to suddenly fail just because a new feature must be added into the test framework.
That could be confusing and counter-productive for anyone who are using it.

2) At the same time, the test framework should be open to extension: ability to add new capability, to address new testing needs.
SQL Unit Testing in ETL context is a pretty new area for us.
Therefore, while the current SQL Unit Test framework appears adequate for most testing now, it must be able to support any new testing needs should they arise in the future.
The test framework should be flexible enough to add new capability to support different kinds of ETLs.

These two are also known as [Open/Closed principle](https://en.wikipedia.org/wiki/Open/closed_principle).
Besides that principle, SQL Test Runner codes also use [**Template Method**](https://en.wikipedia.org/wiki/Template_method_pattern) and [**Strategy**](https://en.wikipedia.org/wiki/Strategy_pattern) design patterns.
Knowing these design patterns will make it easier to understand the overall code structure and package organization of SQL Test Runner.

At the top level, there is a TestRunner interface that any SQL Test Runner class should implement.
For convenience, an abstract class BaseTestRunner is provided as a template with simple processing flow and naive parsing provided in its `runScript` method, as shown below (Template Method design pattern).
The template method `runScript` extracts the SQL statements and test blocks (`/* @Test ... */` blocks), then delegates to `codeHandler` and `testHandler` to process them, respectively.

``` java Template Method for running test scripts in BaseTestRunner
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

In the `BaseTestRunner` class, the `codeHandler` attribute can be any object that implements `CodeStrategy` interface (Strategy design pattern).
It will handle executing SQL statements that are found in the unit test scripts, such as the first two `INSERT` statements in the example script below.
Similarly, the `testHandler` attribute in the `BaseTestRunner` can be any object that implements `TestStrategy` interface.
It will handle test blocks (`/* @Test ... */` blocks) such as the two test blocks in the example script below.
There are many different ways to process a test block: the first test block might be executed using a Vertica-specific interface, while the second one is executed with a generic JDBC interface.
By using the Strategy design pattern, if there is a necessary change in executing SQL code or test blocks, the test framework is flexible enough to easily integrate that change.
 

``` sql Example unit test script
-- This will be handled by some CodeStrategy class
INSERT INTO stg_company_id (company_id,last_modify_date,region_id) 
VALUES (123,current_timestamp-19,'US');

INSERT INTO stg_company_contact (company_id,master_email,last_modify_date) 
VALUES (123,'before@mockdata.com', current_timestamp-15);

-- This will be handled by some TestStrategy class
/* @Test
-- First ETL run
{
	"name" : "Day1_etl_run",
	"vsql_file" : ["repo_home/sql/my_etl.sql"]
}
*/

/* @Test
{
	"name" : "Day1_check_email_address",
	"query" : "select company_id, email_address from dim_company",
	"expected" : "123 before@mockdata.com"
}
*/
```

The `codeHandler` and `testHandler` attributes are undefined in the abstract class BaseTestRunner, leaving the actual test runners to provide with concrete classes when they subclass the BaseTestRunner.
In this way, when another team needs to run a new format of test blocks or run test blocks in a different way, it will only need to define a new class that implements TestStrategy interface to handle those new test blocks.
Then, a new test runner class can be created by simply subclassing the BaseTestRunner, and provide the new TestStrategy class instead.
In the following example TestRunner class, a new `VerticaTestHandler` class is created to handle test blocks that are specific to Vertica, as opposed to generic JDBC-compatible databases.
Other components such as SqlCodeHandler to process SQL statements can be reused for this new TestRunner.

``` java Example TestRunner
/**
 * Test runner that uses Vertica JDBC connection.
 * It can handle test block of NameVsqlfile format that runs ETL scripts using local vsql.
 * 
 * @author tdongsi
 */
public class VerticaRunner extends BaseTestRunner implements TestRunner {
	public VerticaRunner(JdbcConnection jdbcConn, String vsqlPath) {
		this.setCodeHandler(new SqlCodeHandler());
		this.setTestHandler(new VerticaTestHandler(vsqlPath));
		this.setConnection(jdbcConn);
	}
}
```

### Extending Test Runner

When extending a test runner, the behaviors of the test runners should NOT be inherited. 
Instead, they should be encapsulated in classes that specify how to handle SQL statements (CodeStrategy interface) or test blocks `/* @Test {...} */` (TestStrategy interface).
When a new test runner is created to meet new testing needs, we should not subclass the previous test runner.
Instead, we can delegate the old behaviors to the old handlers while adding new classes to handle new behaviors or new functionality.
In other words, "composition over inheritance" principle applies here to separate test runner classes and test processing behaviors that each test runner uses.

Implementation of a new feature can be summarized in the following steps:

1. Design new JSON block for the new test block. 
1. Define new POJO that maps to new JSON block.
1. Create a new class that implements TestStrategy/CodeStrategy interface to handle the new POJO.
1. Create a new test runner that uses the new TestStrategy/CodeStrategy.

For example, our current test runner that can run an ETL script in Vertica database using `vsql` command-line tool.
If we need a test runner that is able to run an ETL script in **Netezza** database, we should not modify our *current* test runner. 
It will break the current suite of tests for Vertica.
Instead, we should create a new test runner class with new class extend TestStrategy to handle running ETL in Netezza.

In [another example](/blog/2016/04/17/sql-unit-data-parity/), I give more detailed steps of implementation when we need to add new capability to SQL Test Runner.

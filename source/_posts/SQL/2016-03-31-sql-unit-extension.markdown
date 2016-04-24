---
layout: post
title: "(Pt. 6) Extending SQL Test Runner"
date: 2016-04-16 17:49:34 -0700
comments: true
categories: 
- SQL
- Automation
- Testing
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
In other words, "composition over inheritance" principle applies here to separate test runner classes and code/test processing behavior that each test runner uses.

#### Example

For example, our current test runner that can run an ETL script in Vertica database using `vsql` command-line tool.
If we need a test runner that is able to run an ETL script in **Netezza** database, we should not modify our *current* test runner. 
It will break the current suite of tests for Vertica.
Instead, we should create a new test runner class with new class extend TestStrategy to handle running ETL in Netezza.

In [this example](/blog/2016/04/17/sql-unit-data-parity/), I give more detailed steps of implementation when we need to add new capability to SQL Test Runner.

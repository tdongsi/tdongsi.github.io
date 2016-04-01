---
layout: post
title: "(Pt. 6) Extending SQL Test Runner"
date: 2016-04-30 17:49:34 -0700
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
From that, I can explain how easily extend the Test Runner to fit new testing needs.
For illustration, I will discuss how I recently added a new functionality to handle a new kind of tests.

### Design of Test Runner

The test runner 


Open Closed principle

Design patterns:

* Template Method
* Strategy

Open to extension: new testing needs will arise.
Close to modifications: all the old tests are passing with old test runners.


The behaviors of the test runners should NOT be inherited. 
Instead, they should be encapsulated in classes that implement CodeStrategy to handle SQL statements or TestStrategy to handle test blocks `/* @Test {...} */`.
When a new test runner is created to meet new testing needs, we should not subclass the previous test runner.
Instead, we can delegate the old behaviors to the old classes while adding new classes to handle new behaviors or new functionality.
In other words, "composition over inheritance" principle applies here to separate test runner classes and code/test handling that each use.

For example, our current test runner that can run an ETL script in Vertica database using `vsql` command-line tool.
If we need a test runner that is able to run an ETL script in **Netezza** database, we should not modify our current test runner. 
It will break the current suite of tests for Vertica.
We should not also subclass the current test runner, in favor of composition.
Instead, we should create a new test runner class with new class extend TestStrategy to handle running ETL in Netezza.

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

### Example

Adding parity tests in the same database.

Set theory

Add new JSON.
Use the old code to handle the old POJOs.

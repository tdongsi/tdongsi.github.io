---
layout: post
title: "AWS: Developing with Amazon DynamoDB"
date: 2016-01-15 10:38:29 -0800
comments: true
published: false
categories:
- AWS 
- Database
- Java
- Python
---

DynamoDB has partition key and sort key, the latter is optional.
Primary key is composed of the partition key and the optional sort key that uniquely identifies an item (ie., "row") in the table.

"The size of an item is the sum of the lengths of its attribute names and values. An item can be a maximum of 400KB in size."

Partition key is also called "hash key" while sort key is also called "range key". The alternatives names are still showed up in DynamoDB's SDKs, such as Java code below.

``` java
    	indexKeySchema.add(new KeySchemaElement()
    	    .withAttributeName("City")
    	    .withKeyType(KeyType.HASH));  //Partition key
    	indexKeySchema.add(new KeySchemaElement()
    	    .withAttributeName("Date")
    	    .withKeyType(KeyType.RANGE));  //Sort key
```



DynamoDB supports both modes of "eventually consistent" and "strongly consistent" reads.

* Eventually consistent read may return slightly stale data if read operation is immediate after a write operation.
* Strongly consistent read returns most up-to-date data.

Streams: analogous to triggers in SQL databases. You can specify streams when creating a table in DynamoDB.

### Lab 3

http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/AboutJava.html

http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/GSIJavaDocumentAPI.html#GSIJavaDocumentAPI.CreateTableWithIndex

Note that the following method of waiting for the table to be active is deprecated:

``` java
        try {
            table.waitForActive();
        } catch (InterruptedException ie) {
            ie.printStackTrace();
        }
```

``` java
    try {
			TableUtils.waitUntilActive( dynamoDbClient, TABLE_NAME );
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
```

http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/JavaDocumentAPIItemCRUD.html#PutDocumentAPIJava


### DynamoDB Links

* Best practices: http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/BestPractices.html
* Data model: http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DataModel.html
* Tables: http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/WorkingWithTables.html
* Secondary indexes: http://docs.aws.amazon.com/amazondynamodb/latest/developerguide/SecondaryIndexes.html


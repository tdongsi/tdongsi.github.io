---
layout: post
title: "An Old Email"
date: 2015-11-19 00:41:40 -0800
comments: true
categories: 
- Java
- JUnit
- Testing
---

I found this email below (names redacted) in an old document folder. It is probably one of the most memorable emails I have ever written. It gave me many significant lessons and insight, especially when I'm relatively early in my job/career:

1. Code that is currently correct may not be robust to changes. Watch out for changes, which are frequent in any software project.
1. A small change in implementation approach can significantly improve testability of your code.
1. Developers and test engineers should NOT be siloed into different departments in any company. They should work closely together, as programmers having different roles (develop vs. test) in a project (hint: Agile). An analogy is forwards/defenders in a soccer match: they are all soccer players, with different roles.
   * Organizational boundaries only dampen open collaboration only if people let them (or abuse them). Send emails, or walk to the other building if needed, to work closely with your project team members.

<!--more-->

***

Hi LeadDeveloper,

I noticed the following problem with enum classes in Project_X. I know that it’s a long email, please bear with me.

For example, the enum class AttributeVisibility is defined as follows:

``` java
public enum AttributeVisibility {
	PublicVisibility(1), 
	PrivateVisibility(2), 
	ProtectedVisibility(4); // Values to match ASM Opcodes

	private int value;

	private AttributeVisibility(int v) {
		value = v;
	}

	public int getValue() {
		return value;
	}

	public static AttributeVisibility getAttributeVisibility(int value) {
		switch (value) {
		case 1:
			return AttributeVisibility.PublicVisibility;
		case 4:
			return AttributeVisibility.ProtectedVisibility;
		case 2:
			return AttributeVisibility.PrivateVisibility;
		}
		throw new RuntimeException("Unable to determine AttributeVisibility");
	}
}
```

Similar to many other enum classes in Project_X, the public static method getAttributeVisibility() in this class uses switch statements to convert an integer to enum data type.

There is nothing wrong with those classes now, but using switch statements is NOT a good practice, as explained below. 

*(STOP: I would encourage blog readers to stop for a few minutes and think why. NOT in the original email)*

In the event of (1) we want to add a new instance, for example, PackageVisibility with value 8 into it, and (2) the developer is unaware of/forgets to update the getAttributeVisibility() method. The case for the new instance PackageVisibility is not added into the switch statement, and the getAttributeVisibility() method is now broken when the input is 8 and PackageVisibility instance is expected to return. One should never rule out that those events (1), (2) ever happen (i.e., they WILL happen) as the project Project_X is evolving.

I believe the better way to do it is to use a map instead of a switch statement (after all, what can express a mapping better than a map?):

``` java
public enum AttributePreferred {
	PublicVisibility(1), 
	PrivateVisibility(2), 
	ProtectedVisibility(4); // Values to match ASM Opcodes
	// PackageVisibility(8);

	private static Map<Integer, AttributePreferred> intToEnum = new HashMap<>();

	static {
		for (AttributePreferred member : AttributePreferred.values()) {
			intToEnum.put(member.getValue(), member);
		}
	}

	private int value;

	private AttributePreferred(int v) {
		value = v;
	}

	public int getValue() {
		return value;
	}

	public static AttributePreferred getAttributeVisibility(int value) {
		AttributePreferred obj = intToEnum.get(value);
		if (obj == null)
			throw new RuntimeException(
					"Unable to determine AttributeVisibility");

		return obj;
	}
}
```

Please note the static initialization block and the updated getAttributeVisibility method. In some enum classes that do not have the private value field such as DiskFormat, the intention may be concisely expressed by the ordinal() method in the static initialization block:

``` java DO NOT do this
	static {
		for (DiskFormat member : DiskFormat.values()) {
			intToEnum.put(member.ordinal(), member);
		}
	}
```

However, using ordinal() method is strongly advised **against** (as indicated in JDK documentation http://docs.oracle.com/javase/7/docs/api/java/lang/Enum.html). Instead, I would recommend that such enum class uses a private value field to specify a fixed integer value for each instance, similar to the class AttributeVisibility above.

As a test engineer, I do have my stake to demand this change. Writing a unit test for such public method like getAttributeVisibility() is pointless, since it would not be better or more efficient than visually verifying it (see "silly" test below).

``` java Silly unit test
	// How silly is this test?
	@Test
	public void test() {
		assertEquals(AttributeVisibility.PublicVisibility,AttributeVisibility.getAttributeVisibility(1));
		assertEquals(AttributeVisibility.ProtectedVisibility,AttributeVisibility.getAttributeVisibility(4));
		assertEquals(AttributeVisibility.PrivateVisibility,AttributeVisibility.getAttributeVisibility(2));
	}
```

Even worse, that test won't help in the case that events (1)-(2) happen. In fact, when a developer fails to update the switch statement (event 2), it is not more likely or feasible that a test engineer will be able to visually verify it. It means that those enum classes may be broken any time due to changes. The only way to add confidence in those enum classes is to use the preferred implementation as explained above.

In summary, testers will be helpless if a bug is introduced into one of the Project_X enum classes if the safer alternative is not used instead of switch statements.

Best regards,

Cuong
---
layout: post
title: "Bash programming cookbook"
date: 2015-08-21 12:05:05 -0700
comments: true
categories: 
- Bash
---

The blog lists some frequently used code snippets found in shell programming.

<!--more-->

### Indirect expansion

Using indirect expansion expression `${!var}`, you can use the value of one variable to tell you the name of another vairable.

``` plain Indirect expansion
$ export xyzzy=plugh ; export plugh=cave

$ echo ${xyzzy}  # normal, xyzzy to plugh
plugh

$ echo ${!xyzzy} # indirection, xyzzy to plugh to cave
cave
```

According to `bash` man page, the exceptions to this are the expansions of `${!prefix*}` and `${!name[@]}`.
`${!prefix*}` expands to the names of variables whose names begin with prefix, separated by the first character of the `IFS` special variable. 
When `${!prefix@}` is used and the expansion appears within double quotes, each variable name expands to a separate word.
On the other hand, `${!name[*]}`, if name is an array variable, expands to the list of array indices (keys) assigned in name. 
If name is not an array, expands to 0 if name is set and null otherwise. 
When `${!name[@]}` is used and the expansion appears within double quotes, each key expands to a separate word.

``` plain Exceptions to Indirect Expansion
:~> export myVar="hi"
:~> echo ${!my*}
    myVar

:~> cat temp.sh
#!/bin/bash

letters=(a b c d)
echo ${!letters[*]}
echo ${!letters[@]}

:~> bash temp.sh
0 1 2 3
0 1 2 3
```



Reference:

* [Stackoverflow discussion](https://stackoverflow.com/questions/8515411/what-is-indirect-expansion-what-does-var-mean)
* [Indirect References](http://tldp.org/LDP/abs/html/ivr.html)
* [More experiements](http://ahmed.amayem.com/bash-indirect-expansion-exploration/)

### General reference

* [bash man page](https://linux.die.net/man/1/bash)
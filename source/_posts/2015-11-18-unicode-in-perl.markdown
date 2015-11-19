---
layout: post
title: "Unicode in Perl"
date: 2015-11-18 15:40:20 -0800
comments: true
categories: 
- Automation
- Perl
- Unicode
---

For automation in Perl, Unicode can be a tricky, especially when you want your automated jobs/tests to work across platforms (Windows and *nix). If you have a choice, another scripting language like Python may be better off in dealing with Unicode texts. If you don't have a choice and must use Perl (specifically Perl 5) like I used to, some of these tips may help get you started.

The most common code snippet that I used in my Perl codes when dealing with Unicode texts is the Unicode preamble:

``` [perl] Unicode preamble
#!/usr/bin/env perl
use strict;

##############################################################
#### Unicode preamble
use utf8;      # so literals and identifiers in Perl scripts can be in UTF-8
use warnings;  # on by default
use warnings  qw(FATAL utf8);    # fatalize encoding glitches
use open      qw(:std :utf8);    # undeclared streams in UTF-8
use charnames qw(:full :short);  # unneeded in v5.16

##############################################################

my $name = '你好世界';
my $checkPrint = "Print Unicode variable: $name \n";
print $checkPrint;
```

The first two lines should be included in any Perl script. The following lines are specifically for UTF-8.

Another useful code snippet is for printing Unicode codepoints:

``` [perl] Print Unicode codepoints
my $unicode_helloworld = "\x{4F60}\x{597D}\x{4E16}\x{754C}";
print "Unicode codepoints: $unicode_helloworld\n";
```

More recipes for working with Unicode in Perl 5 can be found in References below.

Choose encoding scheme for the Perl source file on Windows: ANSI

ANSI
What you see is what you get. Same Chinese-named files created as in source code.
Problem with regex matching of Chinese characters: "malformed regex" error.

UTF-8
Not the same Chinese file created. The only correct Chinese is in main.log.
There is no "malformed regex" error. However, the correctly formed regex matching is now useless.

It is likely that you must choose another encoding scheme on *nix. UTF-8 is a likely one.








References:

1. http://perldoc.perl.org/perluniintro.html
1. https://en.wikibooks.org/wiki/Perl_Programming/Unicode_UTF-8
1. http://www.perl.com/pub/2012/04/perlunicook-standard-preamble.html
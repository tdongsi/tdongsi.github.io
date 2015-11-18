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

Unicode preamble

```[perl]
##############################################################
# Unicode preamble
use utf8;      # so literals and identifiers can be in UTF-8
use warnings;  # on by default
use warnings  qw(FATAL utf8);    # fatalize encoding glitches
use open      qw(:std :utf8);    # undeclared streams in UTF-8
use charnames qw(:full :short);  # unneeded in v5.16

##############################################################

my $name = '你好世界';
my $checkPrint = "Print Unicode variable: $name \n";
print $checkPrint;
```

Choose encoding scheme for the Perl source file on Windows: ANSI

ANSI
What you see is what you get. Same Chinese-named files created as in source code.
Problem with regex matching of Chinese characters: "malformed regex" error.

UTF-8
Not the same Chinese file created. The only correct Chinese is in main.log.
There is no "malformed regex" error. However, the correctly formed regex matching is now useless.

It is likely that you must choose another encoding scheme on *nix. UTF-8 is a likely one.




Printing Unicode codepoints:

my $unicode_helloworld = "\x{4F60}\x{597D}\x{4E16}\x{754C}";
print "Unicode codepoints: $unicode_helloworld\n";



References:

http://perldoc.perl.org/perluniintro.html
https://en.wikibooks.org/wiki/Perl_Programming/Unicode_UTF-8
http://www.perl.com/pub/2012/04/perlunicook-standard-preamble.html
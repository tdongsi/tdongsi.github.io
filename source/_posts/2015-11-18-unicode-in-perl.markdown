---
layout: post
title: "Unicode in Perl"
date: 2015-11-18 15:40:20 -0800
comments: true
categories: 
- Automation
- Perl
- Windows
---

For automation in Perl, Unicode can be tricky, especially when you want your automated jobs/tests to work across platforms (Windows and *nix). 
If you have a choice, another scripting language like Python may be better off in dealing with Unicode texts. 
If you don't have a choice and must use Perl (specifically Perl 5) like I used to, some of these tips may help get you started.

<!--more-->

The most common code snippet that I used in my Perl codes when dealing with Unicode texts is this Unicode preamble:

``` perl Unicode preamble
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

The first two lines are standard and should be included in any Perl script. The rest are specifically for dealing with UTF-8 (the most commonly used encoding of Unicode). Another useful code snippet is for printing Unicode codepoints (Quiz: what is the difference between a codepoint and its encoding?):

``` perl Print Unicode codepoints
my $unicode_helloworld = "\x{4F60}\x{597D}\x{4E16}\x{754C}";
print "Unicode codepoints: $unicode_helloworld\n";
```

More recipes for working with Unicode in Perl 5 can be found in References below.

One dilemma you might be facing when your Perl codes run in Windows is to choose which encoding for your script files: ANSI or UTF-8. In my own experience: 

* If the script file encoding is ANSI, I usually have better luck in "What you see is what you get" department: for example, files created in filesystem have the filenames with same Unicode characters, such as Japanese/Chinese characters, in Perl scripts. The downside of ANSI encoding is when I try to do regex matching of those Japanese/Chinese characters, I get "malformed regex" error. 
* If the script file encoding is UTF-8, the files created in filesystem usually have different Japanese/Chinese characters from those in Perl scripts. However, Japanese/Chinese characters in other places such as log files are matching with ones in Perl scripts. There is no "malformed regex" error when doing regex matching. However, that correctly formed regex matching may be useless if you need to do matching for output from filesystem such as "ls" command's output.

<!---
Overall, I used ANSI encoding for my Perl scripts as my automation project at that time has to run on Windows/Linux/Mac and interacts regularly with filesystem.
-->

References:

1. http://perldoc.perl.org/perluniintro.html
1. https://en.wikibooks.org/wiki/Perl_Programming/Unicode_UTF-8
1. http://www.perl.com/pub/2012/04/perlunicook-standard-preamble.html
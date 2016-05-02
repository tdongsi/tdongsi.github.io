---
layout: post
title: "Git: allow-empty when squashing"
date: 2016-05-02 00:15:57 -0700
comments: true
categories: 
- Git
---

``` plain 
pick daefc6e Revert "KSAFE REMOVAL."
squash f3886c2 KSAFE REMOVAL.
squash b4cb02d Update constants.

# Rebase 41ab184..b4cb02d onto 41ab184
#
# Commands:
#  p, pick = use commit
#  r, reword = use commit, but edit the commit message
#  e, edit = use commit, but stop for amending
#  s, squash = use commit, but meld into previous commit
#  f, fixup = like "squash", but discard this commit's log message
#  x, exec = run command (the rest of the line) using shell
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
#
# Note that empty commits are commented out
```

``` plain
$ git rebase -i origin/feature/foobar
You asked to amend the most recent commit, but doing so would make
it empty. You can repeat your command with --allow-empty, or you can
remove the commit entirely with "git reset HEAD^".
rebase in progress; onto 41ab184
You are currently rebasing branch 'feature/foobar' on '41ab184'.

No changes

Could not apply f3886c23589e0964a4483f6454c6edeba7d63fb7... KSAFE REMOVAL.
```

```
$ git commit --amend --allow-empty
[detached HEAD 706f662] Revert "KSAFE REMOVAL."
```

```
MTVL1288aeea2-225:sbg_datasets cdongsi$ git rebase --continue
[detached HEAD 923477f] Revert "KSAFE REMOVAL."
 1 file changed, 3 insertions(+), 3 deletions(-)
Successfully rebased and updated refs/heads/feature/foobar.
```

http://git.661346.n2.nabble.com/Confusing-error-message-in-rebase-when-commit-becomes-empty-td7612948.html

that message comes from "commit --amend", which is called by 
rebase to handle the squash. The "repeat your command" part is 
confusing. The right thing to do here is: 

  git commit --amend --allow-empty 

if you want to have an empty commit, or: 

  git reset HEAD^ 

if you want to have nothing. 

Of course the first one would never occur to you, because it is not 
"your command" in the first place. :) 

We could change it to say "use git commit --amend --allow-empty"
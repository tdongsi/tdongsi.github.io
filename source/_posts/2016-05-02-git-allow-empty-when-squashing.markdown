---
layout: post
title: "Git: allow-empty when squashing"
date: 2016-07-05 00:15:57 -0700
comments: true
categories: 
- Git
---

Many times in Git, we commit some work only to realize that is a mistake, and we should do another way.
The easy way to fix that is to revert the previous commit, a process in which Git creates another commit that undoes exactly everything in the last commit.
After that, we move on with the other way and check in commits for that.
Before pushing everything to the remote branch, as responsible software engineers :), we sometimes want to "squash" the commits to erase the mistake to keep the commit log clean.

<!--more-->

In the example shown below, my commit `daefc6e` was a mistake, and I reverted it with `f3886c2` commit, and then I checked in my correct solution in `b4cb02d` commit.
I wanted to squash those commits in an interactive rebase session, as seen in the following:

``` plain Rebase commands shown in text editor
pick daefc6e KSAFE REMOVAL.
squash f3886c2 Revert "KSAFE REMOVAL."
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

However, `git rebase` always fail in such situations with the following "error" message:

``` plain git rebase fails
$ git rebase -i origin/feature/foobar
You asked to amend the most recent commit, but doing so would make
it empty. You can repeat your command with --allow-empty, or you can
remove the commit entirely with "git reset HEAD^".
rebase in progress; onto 41ab184
You are currently rebasing branch 'feature/foobar' on '41ab184'.

No changes

Could not apply f3886c23589e0964a4483f6454c6edeba7d63fb7... KSAFE REMOVAL.
```

The error message is very confusing. 
When `daefc6e` and `f3886c2` commits are squashed, the net effect is nothing, which is the "empty commit" mentioned in that error message. 
However, retrying the `git rebase` command with `--allow-empty` as said does not work.

``` plain
$ git rebase --interactive --allow-empty 
error: unknown option `allow-empty' 
```

Using `git rebase --continue` does not work as expected: it does not squash three commits into one.

After some Google searching, it turns out that the above error message comes from `git commit --amend`, which is delegated by `git rebase` to handle the squash.
When the message says "repeat your command", it means repeating the `git commit --amend` command, something would never occurs to us.
Therefore, the right thing to do here is repeat `commit` and continue with the interactive rebase session: 

``` plain
$ git commit --amend --allow-empty
[detached HEAD 706f662] Revert "KSAFE REMOVAL."

$ git rebase --continue
[detached HEAD 923477f] Revert "KSAFE REMOVAL."
 1 file changed, 3 insertions(+), 3 deletions(-)
Successfully rebased and updated refs/heads/feature/foobar.
```

By doing that, we will now have all three commits squashed into one and help cleaning up the commit log.

<!--
http://git.661346.n2.nabble.com/Confusing-error-message-in-rebase-when-commit-becomes-empty-td7612948.html
-->
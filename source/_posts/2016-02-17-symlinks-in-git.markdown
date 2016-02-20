---
layout: post
title: "Symlinks in Git"
date: 2016-02-17 11:28:11 -0800
comments: true
published: true
categories: 
- Git
- MacOSX
- Vertica
- Bash
---

### Context

I had folders with many symbolic links in them, linking to other files in the same Git repository.

``` bash Before
$ ls -l link
... link -> /path/to/target
```

Unfortunately after committing into Git, they've turned into plain text files. 
Note that even after committing and pushing into Git, the symlinks still work fine. 
However, after some branch switches and code merges, the symlinks become actual text files with the link target as the contents.

``` bash After
$ cat link
/path/to/target
```

If you unknowningly try to run some symlinks linked to SQL scripts like that, you might endup with numerous errors like this: 

``` plain
vsql:schema_create.sql:1: ERROR 4856:  Syntax error at or near "/" at character 1
vsql:schema_create.sql:1: LINE 1: /Users/tdongsi/Github/my_repo/db_schema/file...
``` 


### Restoring the symlinks

Before going into lengthy discussion on how Git handles symlinks, the quick solution for the above problem is like this:

``` bash
folder=/Users/tdongsi/Github/my_repo/scripts/sql
ls -d1 $folder/* | while read f; do
  ln -sf "$(cat $f)" "$f"
done
```

where `ls -d1 $folder/*` should be replaced with some command that will list exactly the files you want, preferably in full path. 
Note that `-f` option of `ln` command is required to replace the file with the symlink. For example:

``` bash Examples
ls -d1 vertica/*.sql | while read f; do
  ln -sf "$(cat $f)" "$f"
done

ls -d1 bash/* | while read f; do
  ln -sf "$(cat $f)" "$f"
done
```

**Best practice notes**: I think that the following template is preferred to the more common `for f in $(ls *);` `do...done`:

``` bash
ls * | while read f; do
  # command executed for each file
done
```

This is the right way to handle all file names, especially with spaces, since "$f" will still work. 
In addition, `$(cmd)` is the same as 'cmd' (backticks) but it can be nested, unlike using backticks. 
It fact, it's the main reason why the backticks have been [deprecated](http://wiki.bash-hackers.org/scripting/obsolete) from Bash scripting. 

### How Git deals with symlinks

http://stackoverflow.com/questions/1500772/getting-git-to-follow-symlinks-again

No way for restoring symlinks to files.

http://stackoverflow.com/questions/954560/how-does-git-handle-symbolic-links

### Use hard links

In MacOS, hardlink will be lost

Work around: install hardlink.

http://stackoverflow.com/questions/86402/how-can-i-get-git-to-follow-symlinks

### Links

Alternative ways

1. [Restore symlinks](http://superuser.com/questions/638998/easiest-way-to-restore-symbolic-links-turned-into-text-files)
1. [List files](http://stackoverflow.com/questions/246215/how-can-i-list-files-with-their-absolute-path-in-linux)

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

### How Git deals with symlinks

http://stackoverflow.com/questions/1500772/getting-git-to-follow-symlinks-again

No way for restoring symlinks to files.

http://stackoverflow.com/questions/954560/how-does-git-handle-symbolic-links

### Use hard links

In MacOS, hardlink will be lost

Work around: install hardlink.

http://stackoverflow.com/questions/86402/how-can-i-get-git-to-follow-symlinks



### Restoring the symlinks

http://superuser.com/questions/638998/easiest-way-to-restore-symbolic-links-turned-into-text-files

http://stackoverflow.com/questions/246215/how-can-i-list-files-with-their-absolute-path-in-linux


```
folder=/Users/cdongsi/Github/my_repo/scripts/sql/vertica/table/
  ls -d1 $folder/* | while read f; do
  ln -sf "$(cat $f)" "$f"
done
```

where `ls -d1 $folder/*` could be replaced with something that will list exactly the files you wanted.

``` plain Include subfolders
folder=/Users/cdongsi/Github/sbg_datasets/tests/datamart-qe/scripts/sql/vertica/dml/
ls -d1 $folder/**/* | while read f; do
  ln -sf "$(cat $f)" "$f"
done
```

```
ls -d1 data/vertica/*.sql | while read f; do
  ln -sf "$(cat $f)" "$f"
done

ls -d1 bash/* | while read f; do
  ln -sf "$(cat $f)" "$f"
done
```


`-f` is required to replace the file with the symlink.

I find the

```
ls * | while read f; do
  # command executed for each file
done
```

construct very useful. As I know, this is the right way to handle all file names, e.g. if a file name has spaces then "$f" will still work (unlike with for f in $(ls *); do...done).

FYI: $(cmd) is the same as cmd but it can be nested unlike ``.


Links

1. http://superuser.com/questions/638998/easiest-way-to-restore-symbolic-links-turned-into-text-files

---
layout: post
title: "Symlinks in Git"
date: 2016-02-20 11:28:11 -0800
comments: true
published: true
categories: 
- Git
- MacOSX
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

If you unknowingly try to run some symlinks linked to SQL scripts like that, you might end up with numerous errors like this: 

``` plain
vsql:schema_create.sql:1: ERROR 4856:  Syntax error at or near "/" at character 1
vsql:schema_create.sql:1: LINE 1: /Users/tdongsi/Github/my_repo/db_schema/file...
``` 


### Restoring the symlinks

Before going into lengthy discussion on how Git handles symlinks and hard links, the quick solution for the above problem is the following Bash script:

``` bash
folder=/Users/tdongsi/Github/my_repo/scripts/sql
ls -d1 $folder/* | while read f; do
  ln -sf "$(cat $f)" "$f"
done
```

where `ls -d1 $folder/*` should be replaced with some command that will list exactly the files you want, preferably in full path. 
Note that `-f` option of `ln` command is required to replace the file with the symlink. For examples:

``` bash Examples
ls -d1 vertica/*.sql | while read f; do
  ln -sf "$(cat $f)" "$f"
done

ls -d1 bash/* | while read f; do
  ln -sf "$(cat $f)" "$f"
done
```

**Best practice note**: I think that the following template is preferred to the more commonly seen `for f in $(ls *);` `do...done`:

``` bash
ls * | while read f; do
  # command executed for each file
done
```

I think it is the better way to handle all file names, especially with spaces, since `"$f"` will still work. 
In addition, `$(cmd)` is the same as `'cmd'` (backticks) but it can be nested, unlike using backticks. 
It fact, it's the main reason why the backticks have been [deprecated](http://wiki.bash-hackers.org/scripting/obsolete) from Bash scripting. 

### How Git deals with symlinks

How Git deals with symlinks is defined in the [git config](https://git-scm.com/docs/git-config) `core.symlinks`.
If false, symbolic links are checked out as small plain files that contain the link text.
[Otherwise](http://stackoverflow.com/questions/954560/how-does-git-handle-symbolic-links), Git just stores the contents of the link (i.e., the path of the file system) in a 'blob' just like it would for a normal file. 
It also stores the name, mode and type (e.g., symlink) in the tree object that represents its containing directory.
When you checkout a tree containing the link, it restores the object as a symlink.

After the symlinks are checked out as plain text files, I believe it is pretty much no way for Git to restore symlinks again (i.e., follow symlinks inside text files).
It would be an insecure, undefined behavior: what if the symlink as text file is modified? What if the target is changed when moving between versions of that text file?

### Use hard links?

You can use hard links instead of symlinks (a.k.a., soft links). 
Git will handle a hard link like a copy of the file, except that the contents of the linked files change at the same time.
Git may see changes in both files if both the original file and the hard link are in the same repository.  

One of the disadvantages is that the file will be created as a normal file during `git checkout`, because there is no way Git understand it as a link.
Moreover, hard link itself has many limitations, compared to symlinks, such as files have to reside on the same file-system or partition.
In Mac OSX, hard links to directories are not supported. There is a [tool](https://github.com/selkhateeb/hardlink) to do that, but use it with caution.

Finally, it is important to note that hard links to files can be lost when moving between different versions/branches in Git, even if they are in the same repository.
When you switch branches back and forth, Git remove the old files and create new ones.
You still have the copies of the previous files, but they might have totally different inodes, while others (if not in the same Git repo) still refers to the old inodes.
Eventually, the file and its hardl links may be out of sync, and appear like totally unrelated files to Git.
Therefore, using hard links, at best, is just a temporary solution.

### Links

1. [Alternative ways to restore symlinks](http://superuser.com/questions/638998/easiest-way-to-restore-symbolic-links-turned-into-text-files)
1. [Alternative ways to list files](http://stackoverflow.com/questions/246215/how-can-i-list-files-with-their-absolute-path-in-linux)
1. [Git design overview](https://git.wiki.kernel.org/index.php/Git)

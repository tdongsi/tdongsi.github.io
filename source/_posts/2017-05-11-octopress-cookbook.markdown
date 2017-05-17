---
layout: post
title: "Octopress cookbook"
date: 2015-05-11 13:40:13 -0700
comments: true
categories: 
- Git
- Ruby
---

### Deployment

Octopress deploys latest changes with the command `rake deploy`. 
In this `deploy` step, it copies all the latest changes to the generated static HTML site into a `_deploy` folder which is a clone of one of the public branches (`master` or `gh-pages`) of the same repository.
Create `_deploy` folder by using this command.

``` plain Creating _deploy folder for an on-going blog
git clone -b gh-pages git@github.com:user/myproject.git _deploy
```

With Git 1.7.10 and later, add `--single-branch` to prevent fetching of all branches.

Make sure you use the SSH URL for the Github repo since the HTTPS URL will prompt for password for every deployment.
In addition, SSH public/private key pair must be generated and added to the Github accordingly. 
Otherwise, you might get the following errorr:

``` plain Common public key error
## Pushing generated _deploy website
Permission denied (publickey).
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
```

If you get the above message even though the public key is already added to Github, check if you are using the right private key.
Make sure it is added to SSH authentication agent.

``` plain Adding SSH identity file
mymac:octopress tdongsi$ ssh-add ~/.ssh/id_rsa_git
Identity added: /Users/tdongsi/.ssh/id_rsa_git (/Users/tdongsi/.ssh/id_rsa_git)

mymac:octopress tdongsi$ ssh-add -l -E md5
2048 MD5:ef:c1:d6:4e:92:d2:15:2c:ef:c3:72:d6:c6:98:23:e0 /Users/tdongsi/.ssh/id_rsa_git (RSA)

# Verify your connection
$ ssh -T git@github.com
```

The command `ssh-add -l -E md5` can be used to find if there is a matching public key on Github.
See [here](https://help.github.com/articles/error-permission-denied-publickey/) for more information.

### Reference

* [Clone a specific Git branch](http://stackoverflow.com/questions/1911109/how-to-clone-a-specific-git-branch)
* [Clone to a specific folder](http://stackoverflow.com/questions/651038/how-do-you-clone-a-git-repository-into-a-specific-folder)
* [Github instructions on public SSH key](https://help.github.com/articles/error-permission-denied-publickey/)

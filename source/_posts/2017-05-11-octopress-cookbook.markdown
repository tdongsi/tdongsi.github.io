---
layout: post
title: "Octopress cookbook"
date: 2015-05-11 13:40:13 -0700
comments: true
categories: 
- Git
- Ruby
---

### Basic workflow

In summary, the workflow for writing blog in Octopress is as follows:

* `rake new_post["Post title"]`
* Edit & Preview:
  * `rake generate`
    * After this step, the published artifacts are generated in the "public" directory.
  * `rake preview`
    * Published pages will be served locally at "localhost:4000". Preview it in any browser.
    * Updated Markdown files will be regenerated automatically.
* Publish:
  * `rake generate`
    * This step makes sure latest changes are added.
  * `rake deploy`
    * After this step, the content in the "public" directory is copied into "_deploy" directory and git add/commit/push to the remote Github branch.

### Setting up new blog

This section assumes that we will publish in `gh-pages` branch which is more common (publishing in `master` branch only works for `username.github.io` repository).
In general, any project that we work in a repo `foo` (with main development in branches `master`/`develop`) on Github can have associated documentation HTML site in `gh-pages` branch.
Such documentation site can be accessed publicly at "username.github.io/foo/".
Octopress allows easy generation of such static HTML sites.
One can arrange such that each blog post is a tutorial or a documentation page, written in Markdown and "compiled" into HTML.

The process of setting up such a static "documentation" site is as follows:

1. Download the zip file from octopress master branch [here](https://github.com/imathis/octopress). Note that [this link](https://github.com/octopress/octopress) is version 3, which is different.
1. Unzip the zip file into the repo. Rename it to "docs" or "octopress".
1. Commit it to `master` or `develop` branch.
1. Run `rake install` to generate files. Check in the generated files.
1. Create `_deploy` folder for deployment. For new static site, `rake setup_github_pages` works.
1. Start blogging/writing documentation. Use the workflow in the last section: `rake generate` -> `rake preview` -> `rake deploy`.
1. For layout editing, check out one of early commits in [this repo](https://github.com/tdongsi/javascript).

NOTE: when previewing the one published in `gh-pages`, you need to edit "destination: public" in `_config.yml` file to "destination: public/repo_name".

### Add a new page

This section is about adding a new page, opposed to a new post.
The common examples of such page in an Octopress-based blog is "About" page or "Resume" page.
To create a new page, use the following command:

```
rake new_page["About"]
```

This will create a new file at "source/about/index.markdown" and you can edit that file to add content.
After `rake generate` command, the "source/about/index.markdown" will "compiled" into "public/about/index.html" that is displayed in the web browser.
After the page content is ready, you may want to add an "About" link in the navigation bar to that page. 
To do that, edit the file "source/_includes/custom/navigation.html".

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

Recipes:

* [Latex for Math formulas](http://blog.zhengdong.me/2012/12/19/latex-math-in-octopress/)
* [New page](http://gangmax.me/blog/2012/05/04/add-about-page-in-octopress/)
* [Include code from file](http://octopress.org/docs/plugins/include-code/)
* [rake isolate/integrate](https://blog.pixelingene.com/2011/09/tips-for-speeding-up-octopress-site-generation/)
* [Image](http://octopress.org/docs/plugins/image-tag/)
* [Video](https://github.com/optikfluffel/octopress-responsive-video-embed)
  * [Improved ruby code](https://gist.github.com/jamieowen)

Markdown editing tips:

* [Cheat sheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)
* Use  `<!-- more —>` to specify Excerpt.
* Internal link: `(/2012/01/05/hello-world)` gives the link "http://userName.github.io/repoName/blog/2012/01/05/hello-world"

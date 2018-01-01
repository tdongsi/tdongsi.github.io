---
layout: post
title: "Jenkins Plugin Development"
date: 2017-11-29 08:47:17 -0700
comments: true
categories: 
- Jenkins
- Java
- TODO
---

How to create a Jenkins plugin.

<!--more-->

### Basic plugin

Reference:

* [Tutorial](https://github.com/MarkEWaite/hello-world-plugin/tree/jenkins-world-2017)
* [Video](https://www.youtube.com/watch?feature=player_embedded&v=azyv183Ua6U)

### Pipeline plugin

Reference:

* [Tutorial](https://github.com/jglick/wfdev/tree/pipeline)
* [Slides](https://github.com/jglick/wfdev/blob/master/preso.pdf)
* [Developer's guide](https://github.com/jenkinsci/pipeline-plugin/blob/master/DEVGUIDE.md)

### Blue Ocean plugin

``` plain Local development of Blue Ocean plugin
# this will build and run the plugin in local Jenkins
mvn install hpi:run
# this will recompile js & less while editing
npm run bundle:watch
```

***Gotcha***: extension changes won't update without a Jenkins restart.


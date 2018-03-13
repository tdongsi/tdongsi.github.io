---
layout: post
title: "Jsonnet code recipes"
date: 2018-03-12 14:24:32 -0700
comments: true
categories: 
---

If you are working a lot with JSON files, you should know `jsonnet` tool.
Some of the following Jsonnet code recipes might help you.

<!--more-->

### Automated tests

At least, make sure your jsonnet template files can compile.
The following example bash script will find all the manifest files and try to compile that:

``` bash
# Provide a superset of required parameters
for i in `find Project1/manifests Project2/manifests   -name "*.jsonnet"`; 
do
  jsonnet -V param1=1 -V param2=dummy -V param3=1 "${i}" >> /dev/null
done;
# This will lint-test the files, including libsonnet files.
for i in `find Project1 Project2 -name "*.*sonnet"`;
do
  jsonnet fmt -i -n 2 "${i}" --test
done;
```

### Conditional add

Conditionally adding items to a list.

``` json 
  ports: [
           {
             port: $.httpPort,
             targetport: $.httpTargetPort,
           },
           {
             port: $.jnlpPort,
             targetport: 15372,
           },
         ] +
         (if $.sshEnabled then
            [{
              port: $.sshPort,
              targetport: 15373,
            }] else []),
```

Conditionally adding attributes to an object/map.

``` json
  defaultContainerEnv:: {
    LOGGING_STDERR_LEVEL: "ALL",
    JENKINS_USER: "jenkins",
  } + (if $.sshEnabled then {
          SSH_PORT: 7012,
        } else {}
      )
```
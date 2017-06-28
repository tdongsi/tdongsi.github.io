---
layout: post
title: "Docker Image for ETL development in Vertica"
date: 2016-09-01 11:38:27 -0700
comments: true
categories: 
- Vertica
- Docker
---

Docker is Awesome!!!

<!--more-->

I wish I knew Docker earlier, before going through the hassle of creating VMs for local ETL development and testing. 
Docker can make the whole setup even easier.
It can be done in just a few commands, using [a Vertica Dockerfile](https://github.com/tdongsi/vertica/tree/master/docker), created based on [this](https://github.com/wmarinho/docker-hp-vertica).
In addition to easy virtualization, Docker also enables the entire setup can be automated in a script, allowing it to be version-controlled (i.e., [Infrastructure as Code](https://en.wikipedia.org/wiki/Infrastructure_as_Code)). 

Some notes about this Dockerfile, compared to `wmarinho`'s:

* Added new schema, new user and new role as examples. Avoid using `dbadmin` user for development purpose.
* Added Java and Maven for Java-based ETL and automated test execution.
* Demonstrated running Bash and SQL scripts to initialize the container/database.

### How to run

Before running `docker build`, download Vertica Community Edition from https://my.vertica.com/ and place in the same folder as the `Dockerfile`. 
This `Dockerfile` takes "vertica-7.2.3-0.x86_64.RHEL6.rpm" as the install file.

``` plain Windows output
epigineer@epigineerpc MINGW64 /c/Work/Github/vertica/docker (develop)
$ docker build -t vertica .
...

epigineer@epigineerpc MINGW64 /c/Work/Github/vertica/docker (develop)
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED
SIZE
vertica             latest              d2607fa1f457        13 seconds ago
1.638 GB
<none>              <none>              486163abe73f        11 minutes ago
1.638 GB
centos              centos6.6           2c886f766286        8 weeks ago
202.6 MB

epigineer@epigineerpc MINGW64 /c/Work/Github/vertica/docker (develop)
$ docker run -p 5433:5433 --hostname=verthost --privileged=true --memory 4G -t
-i d2607fa1f457 /bin/bash
Info: no password specified, using none
        Starting nodes:
                v_docker_node0001 (127.0.0.1)
        Starting Vertica on all nodes. Please wait, databases with large catalog
 may take a while to initialize.
        Node Status: v_docker_node0001: (DOWN)
        Node Status: v_docker_node0001: (DOWN)
        Node Status: v_docker_node0001: (DOWN)
        Node Status: v_docker_node0001: (DOWN)
        Node Status: v_docker_node0001: (UP)
Database docker started successfully
creating schema
CREATE SCHEMA
creating user
CREATE USER
creating role
CREATE ROLE
grant usage, create on schema
GRANT PRIVILEGE
```

### Troubleshooting Notes

In Mac OSX, remember that the `entrypoint.sh` file should have executable permission. 
Otherwise, you might get the error "oci runtime error: exec: "/entrypoint.sh": permission denied".
After changing the file permission, you have to rebuild the image with `docker build` before `docker run` again.

#### "Insufficient resources" error when running ETL

You might get "Insufficient resources to execute plan on pool general ... Memory exceeded" error when running a large ETL script against the Vertica container. 
For complex ETL, Vertica might need additional memory to execute the query plan. 
Simply setting higher memory allocation using `--memory` option of `docker run` might NOT work if using **Docker Toolbox**. 
To set higher memory allowance, stop the `docker-machine` and set memory as follows:

``` plain
tdongsi$ docker-machine stop
Stopping "default"...
Machine "default" was stopped.

tdongsi$ VBoxManage modifyvm default --memory 8192

tdongsi$ docker-machine start
Starting "default"...
(default) Check network to re-create if needed...
(default) Waiting for an IP...
Machine "default" was started.
Waiting for SSH to be available...
Detecting the provisioner...
Started machines may have new IP addresses. You may need to re-run the `docker-machine env` command.
```

Note that after running the above commands, `docker-machine inspect` still shows `"Memory":"2048"`.
To verify if memory is properly allocated as desired, run `free` command, for example, inside the container to verify.

### Links

* [My Dockerfile for ETL development and testing on Vertica](https://github.com/tdongsi/vertica/tree/master/docker)
* [Original Dockerfile](https://github.com/wmarinho/docker-hp-vertica)
* [Docker](https://www.docker.com/)
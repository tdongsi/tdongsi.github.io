---
layout: post
title: "Docker Image for Vertica"
date: 2016-08-31 01:09:20 -0700
comments: true
categories: 
- Vertica
- Docker
- Java
---

### Using Docker Image for Vertica

### Windows

``` plain
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

### Mac OSX

``` plain
TODO: Output
```

### Troubleshooting notes

TODO

### References

TODO

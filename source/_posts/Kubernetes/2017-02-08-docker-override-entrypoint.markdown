---
layout: post
title: "Docker: Override ENTRYPOINT"
date: 2017-02-08 16:08:02 -0800
comments: true
published: false
categories: 
- Docker
- Jenkins
---

```
tdongsi-ltm4:jenkins tdongsi$ docker run --restart=always 1234567890123.dkr.ecr.us-east-1.amazonaws.com/matrix-jenkins-nodev4-agent:2.60
two arguments required, but got []
java -jar slave.jar [options...] <secret key> <slave name>
 -cert VAL                       : Specify additional X.509 encoded PEM
                                   certificates to trust when connecting to
                                   Jenkins root URLs. If starting with @ then
                                   the remainder is assumed to be the name of
                                   the certificate file to read.
 -credentials USER:PASSWORD      : HTTP BASIC AUTH header to pass in for making
                                   HTTP requests.
 -headless                       : Run in headless mode, without GUI
 -jar-cache DIR                  : Cache directory that stores jar files sent
                                   from the master
 -noreconnect                    : If the connection ends, don't retry and just
                                   exit.
 -proxyCredentials USER:PASSWORD : HTTP BASIC AUTH header to pass in for making
                                   HTTP authenticated proxy requests.
 -tunnel HOST:PORT               : Connect to the specified host and port,
                                   instead of connecting directly to Jenkins.
                                   Useful when connection to Hudson needs to be
                                   tunneled. Can be also HOST: or :PORT, in
                                   which case the missing portion will be
                                   auto-configured like the default behavior
 -url URL                        : Specify the Jenkins root URLs to connect to.
```

```
tdongsi-ltm4:jenkins tdongsi$ docker run --restart=always 1234567890123.dkr.ecr.us-east-1.amazonaws.com/matrix-jenkins-nodev4-agent:2.60 --entrypoint java -jar /usr/share/jenkins/slave.jar
"--entrypoint" is not a valid option
```

```
tdongsi-ltm4:jenkins tdongsi$ docker run --restart=always --entrypoint="java -jar /usr/share/jenkins/slave.jar" 1234567890123.dkr.ecr.us-east-1.amazonaws.com/matrix-jenkins-nodev4-agent:2.60
container_linux.go:247: starting container process caused "exec: \"java -jar /usr/share/jenkins/slave.jar\": stat java -jar /usr/share/jenkins/slave.jar: no such file or directory"
docker: Error response from daemon: oci runtime error: container_linux.go:247: starting container process caused "exec: \"java -jar /usr/share/jenkins/slave.jar\": stat java -jar /usr/share/jenkins/slave.jar: no such file or directory".
ERRO[0001] error getting events from daemon: net/http: request canceled
```

```
tdongsi-ltm4:jenkins tdongsi$ docker run --restart=always --entrypoint="java" 1234567890123.dkr.ecr.us-east-1.amazonaws.com/matrix-jenkins-nodev4-agent:2.60 -jar /usr/share/jenkins/slave.jar -jnlpUrl http://10.252.78.115/computer/slave/slave-agent.jnlp
Failing to obtain http://10.252.78.115/computer/slave/slave-agent.jnlp
java.net.ConnectException: Connection refused
	at java.net.PlainSocketImpl.socketConnect(Native Method)
```

### Reference

* [Guide of Docker Run](https://docs.docker.com/engine/reference/run/)
* [Docker Run CLI options](https://docs.docker.com/engine/reference/commandline/run/)
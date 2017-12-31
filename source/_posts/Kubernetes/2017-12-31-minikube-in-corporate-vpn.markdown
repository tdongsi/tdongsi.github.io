---
layout: post
title: "Minikube in corporate VPN"
date: 2017-12-31 12:40:08 -0800
comments: true
categories: 
- Kubernetes
---

If you are connected to corporate VPN via Cisco's AnyConnect client, you might have problem with starting Minikube.

```
tdongsi$ minikube start --disk-size=50g --kubernetes-version=v1.8.0
Starting local Kubernetes v1.8.0 cluster...
Starting VM...
Downloading Minikube ISO
 140.01 MB / 140.01 MB [============================================] 100.00% 0s

^C
```

<!--more-->

The issue has been extensively discussed in [this bug report](https://github.com/kubernetes/minikube/issues/1099).
I have attempted different approaches for this issue, but none are consistently working.

1. Use OpenConnect for VPN access rather than Cisco's AnyConnect client.
1. Set port forwarding to forward port 8443 on 127.0.0.1 to port 8443 in the minikube VM.
1. Use `--host-only-cidr` option in `minikube start`.

In addition, [this pull request](https://github.com/kubernetes/minikube/pull/1329) supposedly fixes the issue, in v0.19.0 release.
In this post, we will look into each approach.

### Using OpenConnect

[OpenConnect](http://www.infradead.org/openconnect/) is a CLI client alternative for Cisco's AnyConnect VPN.
Here's how you setup OpenConnect on Mac OSX:

1. OpenConnect can be installed via [homebrew](http://mxcl.github.com/homebrew/):

        brew update
        brew install openconnect

1. Install the [Mac OS X TUN/TAP](http://tuntaposx.sourceforge.net/) driver

1. Connect!

        sudo openconnect --user=<VPN username> --cafile=<.pem file from step 4.3> <your vpn hostname>

    The only thing you should be prompted for is your VPN password.  I added the command to my aliases file.

1. To disconnect, just Ctrl-c in the window where you started the VPN connection.

### Port forwarding localhost:xxx -> minikube_IP:xxx



### Reference

* [Bug report & discussion](https://github.com/kubernetes/minikube/issues/1099)
* [OpenConnect instructions](https://gist.github.com/moklett/3170636)
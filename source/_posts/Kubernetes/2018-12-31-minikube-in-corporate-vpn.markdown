---
layout: post
title: "Minikube in corporate VPN"
date: 2018-12-31 12:40:08 -0800
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
[This pull request](https://github.com/kubernetes/minikube/pull/1329) supposedly fixes the issue, in v0.19.0 release.
However, I'm still occasionally seeing the issue.
I have attempted different approaches but they have different degrees of convenience and success in different networks.

1. Use OpenConnect for VPN access rather than Cisco's AnyConnect client.
1. Set port forwarding to forward port 8443 on 127.0.0.1 to port 8443 in the minikube VM.
1. Use `--host-only-cidr` option in `minikube start`.

In this post, we will look into each approach in more details.

### Using OpenConnect

[OpenConnect](http://www.infradead.org/openconnect/) is a CLI client alternative for Cisco's AnyConnect VPN.
Here's how you setup OpenConnect on Mac OSX:

1. OpenConnect can be installed via [homebrew](http://mxcl.github.com/homebrew/):

    ``` plain
    brew update
    brew install openconnect
    ```
2. Install the [Mac OS X TUN/TAP](http://tuntaposx.sourceforge.net/) driver
3. Connect. The only thing you should be prompted for is your VPN password.

    ``` plain
    sudo openconnect --user=<VPN username> <your vpn hostname>
    ```
4. To disconnect, just Ctrl-C in the window where you started the VPN connection.

### Port forwarding localhost:xxx -> minikube_IP:xxx

This approach is the more convenient and more reliable in my experience.
All you need to do is to set up a list of port forwarding rules for minikube's VirtualBox:

```
VBoxManage controlvm minikube natpf1 k8s-apiserver,tcp,127.0.0.1,8443,,8443
VBoxManage controlvm minikube natpf1 k8s-dashboard,tcp,127.0.0.1,30000,,30000
VBoxManage controlvm minikube natpf1 jenkins,tcp,127.0.0.1,30080,,30080
VBoxManage controlvm minikube natpf1 docker,tcp,127.0.0.1,2376,,2376
```

Then, you can set up a new Kubernetes context for working with VPN:

```
kubectl config set-cluster minikube-vpn --server=https://127.0.0.1:8443 --insecure-skip-tls-verify
kubectl config set-context minikube-vpn --cluster=minikube-vpn --user=minikube
```

When working on VPN, you can set `kubectl` to switch to the new context:

```
kubectl config use-context minikube-vpn
```

All Minikube URLs now must be accessed through `localhost` in browser.
For example, the standard Kubernetes dashboard URL such as:

```
tdongsi$ minikube dashboard --url
http://192.168.99.100:30000
```

must now be accessed via `localhost:30000`.
Similar applies to other services that are deployed to minikube, such as `jenkins` shown above.

In addition, the `eval $(minikube docker-env)` standard pattern to reuse minikube's Docker deamon would not work anymore.

```
tdongsi$ minikube docker-env
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
export DOCKER_CERT_PATH="/Users/tdongsi/.minikube/certs"
export DOCKER_API_VERSION="1.23"
# Run this command to configure your shell:
# eval $(minikube docker-env)

tdongsi$ echo $DOCKER_HOST
tcp://192.168.99.100:2376
tdongsi$ docker images
Cannot connect to the Docker daemon at tcp://192.168.99.100:2376. Is the docker daemon running?
```

Instead, you have to adjust DOCKER_HOST accordingly and use `docker --tlsverify=false ...`.

```
tdongsi$ export DOCKER_HOST="tcp://127.0.0.1:2376"
tdongsi$ alias dockervpn="docker --tlsverify=false"

tdongsi$ dockervpn images
...
```

Finally, when not working on VPN, you can set `kubectl` to switch back to the old context:

```
kubectl config use-context minikube
```

### Use `--host-only-cidr` option

This approach is the most simple but it also has less success than I hoped.
The idea of this approach is that AnyConnect VPN client likely routes `192.168.96.0/19` through its tunnel.
This may conflict with the default Minikube network of `192.168.99.0/24`.
Therefore, we use `minikube start --host-only-cidr 10.254.254.1/24` to instruct minikube to use a different, unused arbitrary network.
It is worth a try but it often does not work in my experience.

### Reference

* [Bug report & discussion](https://github.com/kubernetes/minikube/issues/1099)
* [OpenConnect instructions](https://gist.github.com/moklett/3170636)
* [VBoxManage](https://www.virtualbox.org/manual/ch08.html#vboxmanage-controlvm)
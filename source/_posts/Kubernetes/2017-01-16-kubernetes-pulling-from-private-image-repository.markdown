---
layout: post
title: "Kubernetes: pulling from private image repository"
date: 2017-01-16 11:48:05 -0800
comments: true
published: true
categories: 
- Kubernetes
- Docker
---

**WARNING**: 
This post is for older versions of Kubernetes (< 1.2) with internal corporate constraints. 
Using such old Kubernetes version is not recommended to begin with because of various stability and performance issues.
However, some companies may dive into Kubernetes early, contribute lots of code to make it work and the problem described below may persist, especially for new hires.

### Problem description

In this problem, Kubernetes cluster are all installed and configured. 
We are trying to create some "Hello World" pod, using the example described [here](https://kubernetes.io/docs/user-guide/walkthrough/#pod-definition).

```
tdongsi-mac:private_cloud tdongsi$ kubectl --kubeconfig kubeconfig get nodes
NAME            LABELS                                 STATUS    AGE
kube-worker-1   kubernetes.io/hostname=kube-worker-1   Ready     1d
kube-worker-3   kubernetes.io/hostname=kube-worker-3   Ready     1d
kube-worker-4   kubernetes.io/hostname=kube-worker-4   Ready     1d
tdongsi-mac:private_cloud tdongsi$ kubectl --kubeconfig kubeconfig create -f pod-nginx.yaml
pod "nginx" created
```

However, one can see the following error messages:

```
tdongsi-mac:private_cloud tdongsi$ kubectl --kubeconfig kubeconfig get pods
NAME      READY     STATUS                                                                                       RESTARTS   AGE
nginx     0/1       Image: artifactrepo1.corp.net/tdongsi/nginx:1.7.9 is not ready on the node                   0          4m

tdongsi-mac:private_cloud tdongsi$ kubectl --kubeconfig kubeconfig get events
FIRSTSEEN   LASTSEEN   COUNT     NAME      KIND      SUBOBJECT                           REASON      SOURCE                    MESSAGE
40m         40m        1         nginx     Pod                                           scheduled   {scheduler }              Successfully assigned nginx to kube-worker-3
40m         40m        3         nginx     Pod       implicitly required container POD   pulling     {kubelet kube-worker-3}   Pulling image "gcr.io/google_containers/pause:0.8.0"
40m         39m        3         nginx     Pod       implicitly required container POD   failed      {kubelet kube-worker-3}   Failed to pull image "gcr.io/google_containers/pause:0.8.0":...
)
```

The full error message for the third event above is quoted below:

{% blockquote %}
Failed to pull image "gcr.io/google_containers/pause:0.8.0": image pull failed for gcr.io/google_containers/pause:0.8.0, this may be because there are no credentials on this request.  details: (API error (500):  v1 ping attempt failed with error: Get https://gcr.io/v1/_ping: dial tcp 173.194.175.82:443: i/o timeout. If this private registry supports only HTTP or HTTPS with an unknown CA certificate, please add `--insecure-registry gcr.io` to the daemon's arguments. In the case of HTTPS, if you have access to the registry's CA certificate, no need for the flag; simply place the CA certificate at /etc/docker/certs.d/gcr.io/ca.crt
{% endblockquote %}

### `pause` container

Whenever we create a pod, a `pause` container image such as *gcr.io/google_containers/pause:0.8.0* is implicitly required. 
What is that `pause` container's purpose?
The `pause` container essentially holds the network namespace for the pod. 
It does nothing useful and its container image (see [its Dockerfile](https://github.com/kubernetes/kubernetes/blob/master/build/pause/Dockerfile)) basically contains a simple binary that goes to sleep and never wakes up (see [its code](https://github.com/kubernetes/kubernetes/blob/master/build/pause/pause.c)).
However, when the top container such as `nginx` container dies and gets restarted by kubernetes, all the network setup will still be there.
Normally, if the last process in a network namespace dies, the namespace will be destroyed. 
Restarting `nginx` container without `pause` would require creating all new network setup. 
With `pause`, you will always have that one last thing in the namespace.

What trouble does such `pause` container can give us? 
As the full container image path indicates, the `pause` container image is downloaded from Google Container Registry ("gcr.io") by default.
If a kubernetes node is inside a corporate network with restricted access to Internet, one cannot simply pull that Docker image from Google Container Registry or Docker Hub.
And that is what error message quoted above indicates.
However, each corporate may have its own internal Docker registry with vetted Docker images that you can push to and pull from.
One work-around is to push that `pause` image to the internal Docker registry, downloaded to each Kubernetes slave, and retagged it (from internal tag `artifactrepo1.corp.net` to `gcr.io` tag).
Essentially, I pre-loaded each Kubenetes slave with a `pause:0.8.0` Docker image.

```
tdongsi-mac:private_cloud tdongsi$ docker pull gcr.io/google_containers/pause:0.8.0
0.8.0: Pulling from google_containers/pause
a3ed95caeb02: Pull complete
bccc832946aa: Pull complete
Digest: sha256:bbeaef1d40778579b7b86543fe03e1ec041428a50d21f7a7b25630e357ec9247
Status: Downloaded newer image for gcr.io/google_containers/pause:0.8.0

tdongsi-mac:private_cloud tdongsi$ docker tag gcr.io/google_containers/pause:0.8.0 artifactrepo1.corp.net/tdongsi/pause:0.8.0

tdongsi-mac:private_cloud tdongsi$ docker push artifactrepo1.corp.net/tdongsi/pause:0.8.0
The push refers to a repository [artifactrepo1.corp.net/tdongsi/pause]
5f70bf18a086: Mounted from tdongsi/nginx
152b0ca1d7a4: Pushed
0.8.0: digest: sha256:a252a0fc9c760e531dbc9d41730e398fc690938ccb10739ef2eda61565762ae5 size: 2505
```

The more scalable way, e.g. Puppet automation, is to use `kubelet` option "--pod-infra-container-image".
In the config file "/etc/kubernetes/kubelet" of `kubelet` service, modify the following lines:

``` plain Custom kubelet option
# Add your own! 
KUBELET_ARGS="--pod-infra-container-image=artifactrepo1.corp.net/tdongsi/pause:0.8.0"
```

Note that if the private Docker registry "artifactrepo1.corp.net" requires authentication, specifying the container image in the above `kubelet` option might NOT work.
Instead, the alternative way for scalable automation is to prepare a binary `tar` file for `pause` container image (with `docker save`) and pre-load the image on each kubernetes node with `docker load` command. 
We can upload the binary `tar` file onto new kubernetes nodes whenever each of those is created and added to the kubernetes cluster.

``` plain docker load
docker load -i /path/to/pause-amd64.tar
```

### Pulling fails even with pull image secret

```
tdongsi-mac:private_cloud tdongsi$ kubectl --kubeconfig kubeconfig create -f pod-nginx.yaml
pod "nginx" created

tdongsi-mac:private_cloud tdongsi$ kubectl --kubeconfig kubeconfig get pods
NAME      READY     STATUS                                                                                                                                                                                                   RESTARTS   AGE
nginx     0/1       image pull failed for artifactrepo1.corp.net/tdongsi/nginx:1.7.9, this may be because there are no credentials on this request.  details: (Error: image tdongsi/nginx:1.7.9 not found)   0          50s

tdongsi-mac:private_cloud tdongsi$ kubectl --kubeconfig kubeconfig describe pod
Name:				nginx
Namespace:			default
Image(s):			artifactrepo1.corp.net/tdongsi/nginx:1.7.9
Node:				kube-worker-3/10.252.158.74
Start Time:			Fri, 13 Jan 2017 10:53:39 -0800
Labels:				<none>
Status:				Pending
Reason:
Message:
IP:				10.252.100.2
Replication Controllers:	<none>
Containers:
  nginx:
    Container ID:
    Image:		artifactrepo1.corp.net/tdongsi/nginx:1.7.9
    Image ID:
    State:		Waiting
      Reason:		image pull failed for artifactrepo1.corp.net/tdongsi/nginx:1.7.9, this may be because there are no credentials on this request.  details: (Error: image tdongsi/nginx:1.7.9 not found)
    Ready:		False
    Restart Count:	0
    Environment Variables:
Conditions:
  Type		Status
  Ready 	False
No volumes.
Events:
  FirstSeen	LastSeen	Count	From			SubobjectPath				Reason		Message
  ─────────	────────	─────	────			─────────────				──────		───────
  7s		7s		1	{scheduler }							scheduled	Successfully assigned nginx to kube-worker-3
  7s		7s		1	{kubelet kube-worker-3}	implicitly required container POD	pulled		Container image "gcr.io/google_containers/pause:0.8.0" already present on machine
  7s		7s		1	{kubelet kube-worker-3}	implicitly required container POD	created		Created with docker id 927eadffa4ff
  7s		7s		1	{kubelet kube-worker-3}	implicitly required container POD	started		Started with docker id 927eadffa4ff
  7s		7s		1	{kubelet kube-worker-3}	spec.containers{nginx}			pulling		Pulling image "artifactrepo1.corp.net/tdongsi/nginx:1.7.9"
  7s		7s		1	{kubelet kube-worker-3}	spec.containers{nginx}			failed		Failed to pull image "artifactrepo1.corp.net/tdongsi/nginx:1.7.9": image pull failed for artifactrepo1.corp.net/tdongsi/nginx:1.7.9, this may be because there are no credentials on this request.  details: (Error: image tdongsi/nginx:1.7.9 not found)
```

Validate

```
tdongsi-mac:private_cloud tdongsi$ kubectl --kubeconfig kubeconfig get secret corpregistry -o yaml | grep dockerconfigjson: | cut -f 2 -d : | base64 -D
{ "artifactrepo1.corp.net": { "auth": "XXXXX", "email": "tdongsi@salesforce.com" } }
```

Update secret Type

```
tdongsi-mac:private_cloud tdongsi$ kubectl --kubeconfig kubeconfig get pods
NAME      READY     STATUS    RESTARTS   AGE
nginx     1/1       Running   0          15s
tdongsi-mac:private_cloud tdongsi$ kubectl --kubeconfig kubeconfig get event
FIRSTSEEN   LASTSEEN   COUNT     NAME      KIND      SUBOBJECT                           REASON      SOURCE                    MESSAGE
1m          1m         1         nginx     Pod                                           scheduled   {scheduler }              Successfully assigned nginx to kube-worker-1
1m          1m         1         nginx     Pod       implicitly required container POD   pulled      {kubelet kube-worker-1}   Container image "gcr.io/google_containers/pause:0.8.0" already present on machine
1m          1m         1         nginx     Pod       implicitly required container POD   created     {kubelet kube-worker-1}   Created with docker id 6f874a78acd3
1m          1m         1         nginx     Pod       implicitly required container POD   started     {kubelet kube-worker-1}   Started with docker id 6f874a78acd3
1m          1m         1         nginx     Pod       spec.containers{nginx}              pulling     {kubelet kube-worker-1}   Pulling image "artifactrepo1.corp.net/tdongsi/nginx:1.7.9"
54s         54s        1         nginx     Pod       spec.containers{nginx}              pulled      {kubelet kube-worker-1}   Successfully pulled image "artifactrepo1.corp.net/tdongsi/nginx:1.7.9"
54s         54s        1         nginx     Pod       spec.containers{nginx}              created     {kubelet kube-worker-1}   Created with docker id e2f7ea9c5415
54s         54s        1         nginx     Pod       spec.containers{nginx}              started     {kubelet kube-worker-1}   Started with docker id e2f7ea9c5415
```

### References

* [pause Dockerfile](https://github.com/kubernetes/kubernetes/blob/master/build/pause/Dockerfile)
* [pause source code](https://github.com/kubernetes/kubernetes/blob/master/build/pause/pause.c)

---
layout: post
title: "SSH cookbook"
date: 2017-05-11 13:45:35 -0700
comments: true
categories: 
- Security
- Bash
---

### `ssh-add`

#### Simple usages

``` plain Adding identity file
ssh-add /path/to/file/id_rsa.pem
```

``` plain Listing identities
# Display the keys' fingerprints only
ssh-add -l
# Display the entire public key
ssh-add -L
```

``` plain Deleting identity
# Delete a key
ssh-add -d /path/to/file
# Clear all keys
ssh-add -D
```

#### OSX specific

On OS X `ssh-add` is integrated with the system keychain. If you give the `-K` option, as in `ssh-add -K`, when you add a key, that key’s password will be added to the keychain. As long as your keychain is unlocked, a key that has been stored in this way doesn’t require a password to be loaded into the agent.

All keys with their password stored in the keychain will automatically be loaded when you run `ssh -A`. This happens automatically on login.

When a password has been stored in keychain, `ssh -K -d key-file` both removes the key from the agent and removes it password from the keychain. Without `-K`, `-d` does not change the keychain and the key can be reloaded without a password. `-D` silently ignores `-K`.

#### Recipe: Connecting without a passphrase

``` plain Before
tdongsi-wsm:~ tdongsi$ ssh -i ~/.ssh/cloud.key centos@k8s-worker-10
Enter passphrase for key '/Users/tdongsi/.ssh/cloud.key':
Last login: Mon May 15 20:17:13 2017 from 10.3.52.223
[centos@k8s-worker-10 ~]$ exit
logout
Connection to k8s-worker-10 closed.
```

``` plain After
tdongsi-wsm:~ tdongsi$ ssh-add ~/.ssh/cloud.key
Enter passphrase for /Users/tdongsi/.ssh/cloud.key:
Identity added: /Users/tdongsi/.ssh/cloud.key (/Users/tdongsi/.ssh/cloud.key)
tdongsi-wsm:~ tdongsi$ ssh-add -l
2048 SHA256:WKysqi9jq72UntuIszBhmOeLj7ho4e35mRK0U2MNS5A /Users/tdongsi/.ssh/cloud.key (RSA)

tdongsi-wsm:~ tdongsi$ ssh centos@k8s-worker-10
Last login: Mon May 15 20:23:46 2017 from 10.10.74.67
[centos@k8s-worker-10 ~]$ exit
```

### Reference

* [ssh-add](https://help.github.com/articles/error-permission-denied-publickey/)
  * [ssh-add tips](http://stuff-things.net/2016/02/11/stupid-ssh-add-tricks/)

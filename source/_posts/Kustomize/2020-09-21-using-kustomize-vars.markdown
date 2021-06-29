---
layout: post
title: "Using Kustomize vars"
date: 2020-09-21 03:45:44 -0700
comments: true
published: false
categories: 
- Kustomize
---

## Tips

Loop through all Kustomize variants and run Kustomize.

```bash
#!/usr/bin/env bash -x

for mydir in $(find . -iname kustomization.yml | xargs -L 1 dirname); do
  if [[ ! ${mydir} == "./base" ]]; then
    # echo "$mydir"
    cd "$mydir";
    # kustomize build --load_restrictor=none . >output/all.yml;
    ls;
    cd ../..;
  fi
done 
```

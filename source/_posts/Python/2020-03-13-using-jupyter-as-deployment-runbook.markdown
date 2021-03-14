---
layout: post
title: "Using Jupyter as deployment runbook"
date: 2020-03-13 22:29:40 -0800
comments: true
categories: 
- Jupyter
- Python
---

We have great success in using Jupyter for our runbooks in Production Launch exercises.

<!--more-->

### Disadvantages of Jupyter runbooks

Learning curve: works best if most members of the Release Management/DevOps team are proficient in Python and Python is the primary language for other supporting tools.

Jupyter interface itself is a bit hard to navigate for beginners but anyone should be able to get familiar with it within a few hours. TODO: shortcuts

No interaction: Jupyter can only shine when the runbooks getting really long and complicated. 
To the point that non-technical and higher management would prefer quick summaries instead of checking the current status.
Adopting Jupyter, therefore, is hard at the beginning since people prefer everything in one place.
Later one, due to inertia, it's hard to move to Jupyter, you prefer to keep copying/pasting different versions of runbook in Quip, Google Doc, or Confluence pages.

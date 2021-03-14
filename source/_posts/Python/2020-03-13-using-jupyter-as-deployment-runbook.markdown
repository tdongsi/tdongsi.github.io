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

### Motivations

Why Jupyter?

* [Literate programming](https://en.wikipedia.org/wiki/Literate_programming): Code snippets executed in sequence, surrounded by context & explanations intended for human operators (vs. script order imposed by computer).
* Convenience: Less copy & paste between runbook and terminals.
* Quick reset: Fresh copy of runbook on-demand for fixing News daily deployments.
* Archive: Sharable/Viewable copies saved in GHE with timestamps and details for past milestone deployments.
* Easy evolution: Runbooks change overtime with releases. Runbooks for new releases can be done with branching/merge like codes.
* Easy retry: Enough control in each step so that human operators can do monitoring, adjustment, rollback before proceeding to next step.
* Extendable: UI elements such as checkboxes can be programmed in Python to add functionality (e.g., timestamped) if needed. In other words, a "programmable Quip/Google Doc".

#### Literate programming

TODO: Separate automation for high-stake Prod launch and nightly auto deployments.

#### Archive in Github

TODO: Jupyter notebook auto-rendered in Github.

#### Easy revolution/retry

Branching to create new runbook copy for new environment.

#### Extendable

TODO

* Generate timestamps for book keeping
* Generate Splunk queries

### Best practices

Please keep Jupyter as **"runbook" intended for human operators**.  

DON'Ts:

* Don't go overboard with all low-level Python codes in Jupyter runbok. 
  * To keep runbook at the high level logics & context, low-level logics (e.g., network retry) should be automated in Python modules and imported into runbook.
* Don't over automate: In another extreme, for example, ones often may want to automate generating the similar steps in the runbook (e.g., generating similar steps from list of strings). 
  * Use your judgement and avoid obfuscating the runbook for little gains. 
  * The runbook is intended for using in high-stake Production Launch exercises. Full automation can be and should be done elsewhere (e.g. Jenkins), **in addition** to Jupyter runbook.

#### Installation tips

The following Jupyter extensions are recommended for using Jupyter as deployment runbook.

* [execute_time/ExecuteTime](https://jupyter-contrib-nbextensions.readthedocs.io/en/latest/nbextensions/execute_time/readme.html): automatically adding timestamps when running a Jupyter cell.
* [toc2/main](https://towardsdatascience.com/jupyter-notebook-extensions-517fa69d2231): Table of Contents. For quick navigation between sections (i.e., services to deploy). See example below.
* livemdpreview/livemdpreview: Live Markdown rendering when editing Markdown block.
* [notify/notify](https://jupyter-contrib-nbextensions.readthedocs.io/en/latest/nbextensions/notify/readme.html): Notify (in browser) when a long command is completed.

```
$ jupyter nbextension list
Known nbextensions:
  config dir: /Users/tdongsi/.jupyter/nbconfig
    notebook section
      execute_time/ExecuteTime  enabled
      - Validating: OK
      ExecuteTime disabled
      collapsible_headings/main  enabled
      - Validating: OK
      toc2/main  enabled
      - Validating: OK
      nbextensions_configurator/config_menu/main  enabled
      - Validating: problems found:
        - require?  X nbextensions_configurator/config_menu/main
      codefolding/main  enabled
      - Validating: OK
      jupyter-js-widgets/extension  enabled
      - Validating: OK
      livemdpreview/livemdpreview  enabled
      - Validating: OK
      notify/notify  enabled
      - Validating: OK
      contrib_nbextensions_help_item/main  enabled
      - Validating: OK
    tree section
      nbextensions_configurator/tree_tab/main  enabled
      - Validating: problems found:
        - require?  X nbextensions_configurator/tree_tab/main
  config dir: /Users/tdongsi/Matrix/sample-runbooks/venv2/bin/../etc/jupyter/nbconfig
    notebook section
      jupyter-js-widgets/extension  enabled
      - Validating: OK
      voila/extension  enabled
      - Validating: OK
```

### Other usage tips

TODO: For long runbooks, status updates should be done elsewhere.

Quip/Google Docs can be used to provide a shared location for discussion among Deployment team.
For example, we want to share links if there is something odd happening during the deployment.
In addition, we can also use a Slack channel (e.g., `#prod-deployments`) for discussion on the deployment date.

It is recommended to have a single driver to take control of one instance of Jupyter runbook.

TODO: "Scatterer-Gatherer" pattern. This single driver, usually the Release Manager/Launch Coordinator, will assign tasks (i.e., review services).

### Disadvantages of Jupyter runbooks

Learning curve: works best if most members of the Release Management/DevOps team are proficient in Python and Python is the primary language for other supporting tools.

Jupyter interface itself is a bit hard to navigate for beginners but anyone should be able to get familiar with it within a few hours. TODO: shortcuts

No interaction: Jupyter can only shine when the runbooks getting really long and complicated. 
To the point that non-technical and higher management would prefer quick summaries instead of checking the current status.
Adopting Jupyter, therefore, is hard at the beginning since people prefer everything in one place.
Later one, due to inertia, it's hard to move to Jupyter, you prefer to keep copying/pasting different versions of runbook in Quip, Google Doc, or Confluence pages.

#### Editing tips

Useful Jupyter shortcuts when editing:

* `Esc`: enter Help mode.
  * `H`: Show all shortcuts.
  * `A`: Insert cell **A**bove.
  * `B`: Insert cell **B**elow.
  * `Y`: Current cell mode to Code.
  * `M`: Current cell mode to Markdown.
  * `Enter`: exit Help mode (enter Edit mode).


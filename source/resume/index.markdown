---
layout: page
title: "Cuong Dong-Si"
date: 2016-12-07 13:49
comments: true
sharing: false
footer: true
published: true
---

My resume in HTML format.

* Email: dongsi.tuecuong@gmail.com
* [LinkedIn](https://www.linkedin.com/in/cuong-dong-si-479b326)
* [PDF version](/download/Resume.pdf) (slightly outdated)

<!--
Checklist:

1. Unify the following versions: LinkedIn, PDF, Web (github.io).
2. Enable Publications section?
3. Compare Skills section vs Blog categories.
-->

### Skills

<!--
Want to do: 
-->
<!-- SKIPPED:
* Languages: Matlab, [Perl](/blog/categories/perl/).
* Database: XPath, XQuery.
* Java stack: 
  * Libraries: Guava, SLF4J, JCommander, [Swing](https://github.com/tdongsi/java/tree/master/my.vip.applets), [JDBC](/blog/categories/jdbc/)
  * Build: Ant, sbt (Scala)
  * Test: Gatling, JMeter, JMockit, RestAssured.
* Python stack: PyPI, virtualenv.
* **Ruby stack**: rake, Gem/Bundle, Rails.
* JavaScript stack: ExpressJS, MongoDB.
* Others: ANTLR, Boost, OpenCV, Eigen
* Platform: SunOS, HP-UX
* Big Data: Dimensional Modeling (Kimball), Netezza, Tableau
* Tools:
  * DevOps: Datadog, SonarQube, Nexus, VMWare, VirtualBox
  * Teamware: MediaWiki, Confluence
  * Version control: Subversion
  * IDE: Visual Studio
  * Configuration: Pulumi, Terraform, Puppet, Ansible, Chef,
  * Virtualization: Vagrant,
-->
* **Language**: 
  [Java](/blog/categories/java/),
  [Python](/blog/categories/python/), 
  Scala, Groovy, Javascript, 
  Go, C/C++,
  Ruby,
  [bash](/blog/categories/bash/). 
* **Java stack**: 
  IntelliJ, Eclipse, 
  Spring, Grails,   <!-- Frameworks -->
  Swagger,  <!-- Libraries -->
  [Jacoco](/blog/2017/09/23/jacoco-in-maven-project/),
  [JUnit](/blog/categories/junit/), TestNG, Spock, <!-- Test -->
  [Maven](/blog/categories/maven/), Gradle. <!-- Build -->
* **Python stack**:
  PyCharm, Jupyter, JupyterHub, 
  Pandas, <!-- Data manipulation -->
  [Numpy](/blog/categories/numpy/), [Matplotlib](/blog/categories/matplotlib/), <!-- Matlab -->
  Flask, Django.  <!-- Web Framework -->
* **Web stack**:
  Node.js, React.js, jQuery, <!-- Framework -->
  Grunt, npm, Webpack, <!-- Build -->
  Jasmine, Mocha, <!-- Test -->
  HTML/CSS.
* **Platform**: 
  [Windows](/blog/categories/windows/), 
  [Mac OS](/blog/categories/macosx/), 
  [CentOS](/blog/categories/centos/),
  Ubuntu,
  [Docker](/blog/categories/docker/), Kubernetes, <!-- Container -->
  [AWS](/blog/categories/aws/), GCP,
  Heroku.
* [**Database**](/blog/categories/database/): 
  [Cassandra](/blog/categories/cassandra/),
  HBase,
  [SQLite](/blog/categories/sqlite/), 
  [MySQL](/blog/categories/mysql/),
  [SQL](/blog/categories/sql/).
* **Big Data**:
  [Hive](/blog/categories/hive/)/[Hadoop](/blog/categories/hadoop/),
  Spark,
  Kafka,
  [Vertica](/blog/categories/vertica/),
  Data Warehouse.
* **Tools**:
  [Jenkins](/blog/categories/jenkins/), Spinnaker, ArgoCD, <!-- CI/CD --> 
  [Splunk](/download/training/COC_Searching_Splunk.pdf), Prometheus, Grafana, <!-- Monitoring --> 
  Pulumi, Terraform, <!-- Configuration -->
  [Git](/blog/categories/git/), 
  [Github](https://github.com/tdongsi), 
  SourceTree, 
  Perforce, <!-- Version Control --> 
  JIRA, Trello, Slack. <!-- Teamware --> 
 
### Honor & Awards

* [**Salesforce Spot Bonus**](/download/awards/2018_Spot_Bonus.pdf) [March 2018]: for "absolute dedication and ownership".
* [**IoT Rock Star Award**](/download/awards/2017_IoT_Star.jpg) [April 2017]: for delivering [a scalable CI/CD system used in Salesforce IoT](/download/awards/2017_IoT_slide.jpg).
* **Winner - Best Idea** [August 2016]: Member of winning team “Ahab” for Best Idea category in Intuit Small Business Group's Data Hackathon. 
* [**Intuit Spotlight Award**](/download/awards/2016_Deliver_Awesome.pdf) [June 2016]: Peer's spot award for [“Deliver Awesome”](https://about.intuit.com/about_intuit/operating_values/).
* [**Intuit Spotlight Award**](/download/awards/2015_Deliver_Awesome.pdf) [August 2015]: Manager's spot award for [“Deliver Awesome”](https://about.intuit.com/about_intuit/operating_values/).
* [**Intuit Spotlight Award**](/download/awards/2015_Learn_Fast.pdf) [March 2015]: Manager's spot award for [“Learn Fast”](https://about.intuit.com/about_intuit/operating_values/).
* [**IEEE ICRA Travel Award**](/download/awards/ICRA_2012_Travel.pdf) [2012], by **National Science Foundation**.
* [**IEEE ICRA Travel Award**](/download/awards/ICRA_2011_Travel.pdf) [2011], by **IEEE Robotics and Automation Society**.
* **Dean’s Distinguished Fellowship** [2009], by **University of California, Riverside**.
* **Singapore Scholarship** [2002-06], full tuition & allowance scholarship for top ASEAN undergraduates.
* **Dean’s List**, Faculty of Engineering, National University of Singapore [2002-04].

<!--
* **Best committee member certificate**, IEEE NUS Student Brach Annual General Meeting [2005].
* **Champion**, IEEE All-Singapore University Tech Quiz [2005, 2006].
* **First Prize**, Vietnam National Physics Olympiad for Universities [2002]
* **Merit Prize**, Vietnam National Physics Olympiad for High Schools [2001]
-->

### Work Experience

**Senior SDE**, <a name="Apple">Apple</a> (7/2018 - present)

* [Apple News & Stocks](https://www.cnet.com/news/apple-news-adds-browse-tab-brings-news-to-stocks/).

<!-- 2021
Key achievements?

ArgoCD: setting up ArgoCD instances (beta/prod). Fully integrated with other systems in Apple such as ProdGit OAuth for authentication/authorization, Prometheus/Grafana for monitoring. Advised the team on best usage practices, integration with CI/CD pipelines for GitOps implementation. Upgraded and scaled up ArgoCD prod to host applications for Solr infra monitoring as well as DEVEL/TEST services for ACI Kube migration.

Orca-Jenkins: working with Data Engineering team and DataOps for general migraiton of Orca-Jenkins to ACI Kube: migration of Jenkins configurations to ACI Kube-based ConfigMaps, migration of classic jobs to Pipeline-based jobs for more resilience against container restarts, ArgoCD/Kustomize for Jenkins updates/deployments. 

CI/CD: First implementations of nightly deployment and on-demand deployment for ACI Kube: Docker images for Jenkins agent to execute Gradle/ArgoCD commands, basic automation scripts, Jenkins shared library for orchestration. On-going project.

ACI Kube migration: 
* url-bucketing-service: Swift-based service into ACI-Kube. Implemented automated deployment Jenkins jobs (Kustomize-based, not PCL-based) for Weian.
* anf-toolbox migration with PCL: Porting anf-toolbox repo to ACI Kube using PCL: 3 services, convert Gneiss team's/Independent Release idiosyncrasies in Slug build/PIE deployment into corresponding Gradle jib/PCL-based configs. 
* Work with News-SRE for utility/Background services and other implementations: Access control policies, event-watchers for logging events into Splunk and helping troubleshooting, pod-reaper for automatic cleanup

Misc: 
* Refactoring and continue improving Jupyter runbook: more readable and easier-to-update Splunk queries and better generation of clickable URLs (use in runbook/sent to Slack). 
-->

<!-- 2020
What were your key achievements?

* Lead the DevOps initiative to migrate from error-prone Quip runbooks to Jupyter-based runbooks. 
  Designed and implemented the first version of Jupyter runbook and used it for 1.39 release as the release DRI.
  Started some of deployment-day's best practices: single driver controlling the runbook, explicit monitoring assingments among the DevOps team.
* CI/CD: Optimized nightly deployments to DEVEL/TEST/QA and reduced average deployment times from 3 hours to 1h45+ mins. 
  Investigated and restored PRBs for Algorithms and Authoring repos, generalized the PRBs with regex to reduce tasks on branching days. 
* Blazing the trails for APC/ACI Kube migration:
  * Brought up ops-webapp and acb-service in APC and ACI Kube as the sample applications for others to follow. 
    Designed and implemented general strategy for YAML templating with Kustomize and Kustomize plugins. 
    Implemented various integration with Apple’s other internal services: Splunk logging, Hubble metrics, ACI services, credentials management, ACL management, etc.
  * Recommended DevOps team on general architecture/strategy in ACI Kube in various aspects: YAML templating (Helm vs. Kustomize vs. Terraform), secret management (Vault vs. k8s Secrets), access management (RBAC), namespace (Mega namespace vs team namespace), general News conventions in Kube (e.g., container name, labels).
  * Identified and resolved early issues in APC/Kube (networking in APC, DNS issue in ACI Kube us-west-2a). Identified and documented differences between APC v1 vs ACI Kube v2.
  * Worked with external teams: 
    Worked with ACI Kube to identify the potential scalability blockers for ACI Kube migration and created radars for ACI Kube Scale team to request further testing. 
    Work with News-SRE, bring Sharan up to speed with Kubernetes and improved ACL based on their feedback.
  * Regularly demoed and presented various Kube and/or Kubernetes features with DevOps team as well as external teams (DataEng, ACB team) to help with Kube onboarding. 
* Contributed and provided Kubernetes consultation/feedback for News-Solr in Kube project:
  * Implemented Grafana in APC (integrated with Apple LDAP for authentication, Apple Directory ACL groups for authorization). 
    Sample dashboard to show how to integrate with Prometheus for monitoring when Mosaic is not yet available.
  * General advices on architecture: Job/CronJob for running CLIs, advices on HA setup for Prometheus/AlertManager stack.
* Provided support to teams in Apple News: 
  * DataEng support: Extended pie-cli to add Spark deployment functionality for Data Engineering. 
    Laid out the framework so that Okehee/Liang can further contribute from DataEng side. 
    Took consultation role for general Orca-Jenkins troubleshooting, advised DataEng team on general architecture of Jenkins in Kubernetes and their general migration journey to ACI Kube.
-->

<!-- 2019
What were your key achievements?

* Modernized Jenkins-based deployment pipelines for DEVEL/TEST/QA/STAGING: from separate, divergent, GUI-based Jenkins pipelines to unified, code-based pipelines.
  * Refactored large code sections shared by 4 pipelines into "Jenkins shared library" to reduce copy & paste-ing code.
* PIE CLI, Secrets CLI: Made the tools more resilient against exceptional scenarios (e.g., 4xx/5xx from PIE APIs).  Added numerous functional & unit tests to prevent regressions, introduced mocking as proof of functionality.
* Improved secret management practices for DevOps tools and code: using Jenkins secret files and environments, dashboard of credential usages, internal Secrets v2 migration.
* Implemented Jenkins Splunk dashboards for DevOps-Jenkins and News-Orca. 
* Jupyter deployment runbook: demonstrated in News Hackathon. Personal use for 1.34 Staging/Prod launches and ad-hoc fixes for nightly QA deployments.
* News-Publisher in a Pod: investigated issues, fixed problems. Extended the pod (i.e., adding services) to support additional development needs of News Publisher team.  
-->

**Senior Member of Technical Staff**, <a name="Salesforce">Salesforce</a> (10/2016 - 6/2018)

* Salesforce IoT. Worked with AWS, Kubernetes, Docker, Jenkins, Groovy/Java, CI/CD.
* Achievements:
  * Designed and implemented [a solid CI/CD platform](/download/awards/2017_Promotion.jpg) from scratch as the foundation for [launching IoT Explorer](http://www.zdnet.com/article/salesforce-launches-iot-explorer-aims-to-bring-sensor-data-to-business-users/) into production. 
  * Built a robust, highly-available **Kubernetes** infrastructure on top of internal Compute services at Salesforce (similar to AWS EC2 & S3).
  * Designed and implemented highly-available **Prometheus** and **AlertManager** stack for monitoring Kubernetes infrastructure.
    Integrated with PagerDuty and Slack for notification and **Grafana** for visualization and dashboards.
  * Designed and implemented **fully containerized Jenkins systems** (production and experimental) running on the above Kubernetes infrastructure, integrated with other systems and services such as Github/GHE, DockerHub, Artifactory, Nexus, Slack, PagerDuty. 
  * Implemented various key features such as Docker images, access control, Jacoco-based code coverage gates, Slack/email notifications.
    Contributed extensively to the shared global Groovy library for Jenkins to reduce code duplication and ease Jenkins pipeline configuration for developers.
    Built solutions and infrastructure for front-end CI/CD (Dockerized Headless browser, PhantomJS).
  * Designed and implemented Kubernetes-backed micro-services for continuously syncing Github/GHE commits to [GUS](https://developer.salesforce.com/blogs/engineering/2014/08/meet-gus-keeping-salesforce-agile.html), integrating HBase schema upgrade to Perforce, and posting to [Chatter](https://www.salesforce.com/products/chatter/overview/) on build successes.
<!--
  * Security Champion for the team: championing for best practices for secure, scalable, highly-available services.
-->

**Software Engineer II**, <a name="Intuit">Intuit</a> (12/2014 - 10/2016) 

* Designed and implemented automation frameworks and tools for **Big Data** projects for QuickBooks Online and Small Business Group (SBG) ecosystem. 
  Worked with business analysts and data scientists on project requirements to develop appropriate tools and automation solutions.
* Projects and Achievements:
  * Designed and implemented a test automation framework to facilitate automated unit/functional testing of **SQL scripts**, 
    verifying Extract-Transform-Load (**ETL**) processes between data sources (e.g., Netezza, Hive, HDFS, Vertica), and validating data consistency and integrity.
  * Member of team ["Ahab"](https://en.wikipedia.org/wiki/Moby-Dick) that won Intuit Data Hackathon: 
    Using Docker containers to recreate data warehouse infrastructure and pipelines in local environment for efficient ETL development and testing.
  * Three **Intuit Spotlight Awards** for demonstrating Intuit Values: [“Learn Fast”](/download/awards/2015_Learn_Fast.pdf) 2015, [“Deliver Awesome”](/download/awards/2015_Deliver_Awesome.pdf) 2015, and [“Deliver Awesome”](/download/awards/2016_Deliver_Awesome.pdf) 2016.
  
**Software Engineer**, Objectivity Inc. (7/2012 - 12/2014)

* Designed and implemented automation frameworks to facilitate scalable testing for company’s database products, Objectivity and InfiniteGraph.
* Selected Projects and Achievements:
    * Designed and implemented performance benchmark for measuring data ingestion performance of graph database InfiniteGraph in distributed settings, 
      including automated performance test framework in Python that orchestrate Java-based clients ingesting data simultaneously from multiple remote Windows and Linux hosts.
    * Designed and developed an automated test suite for testing Java byte code injection tools, including a custom Java parser (based on ANTLR) to verify correctness of decompiled byte codes after injection.
    * Developed functional tests for Talend data connectors in ETL pipelines for transforming data from MySQL and Cassandra databases to Objectivity databases.
    * Reviewed Java codes and enforced good practices for more robust and flexible Java API.

<!--
*Selected Projects and Achievements*:

* Designed and implemented test plans for measuring data ingestion performance of graph
  database InfiniteGraph in distributed multi-client settings. Set up and configured a network of eight Linux and Windows hosts with OpenSSH. Fully automated performance tests using Python scripts, in which multiple Java test applications are compiled and ingest data simultaneously from multiple remote hosts.
* Designed and developed an automated test suite for testing Java byte code injection tools, including a custom Java parser (based on ANLTR) to verify correctness of decompiled byte codes after injection.
* Developed generic-based JUnit tests for database-backed Java collection classes, based on Guava library. 5000+ JUnit tests effectively added into nightly test suite within a month.
* Developed functional tests for Talend data connectors that convert data from MySQL and Cassandra databases to Objectivity databases.
* Developed performance tests for Objectivity/DB with different network configurations and use cases to check for performance regressions. Automated generating performance reports from raw performance logs using Python.
-->

**Research Software Engineer**, National University of Singapore. (8/2006 - 7/2009)

* Worked in driverless car projects, a collaboration effort of multiple Singaporean industrial research labs, managed by Defense Science Organization (DSO), Singapore.
* Designed, implemented and evaluated computer vision algorithms for [visual sensor modules](/resume/calibration_2007.jpg). 
  Designed and implemented an adaptive machine learning algorithm to identify drivable road surface from stereo images, by building statistical models of road appearance.
* My (part-time) [Master of Engineering thesis](/download/pubs/MEng.pdf) sums up work during that period.

<!--
**Summer Intern**, Singapore Institute of Manufacturing Technology (5/2005 - 7/2005) 

* Investigated feasibility of using Java technologies for embedded systems, using TStik, STEP and TILT circuit boards and TINI development tools.
* Implemented several Java applications to interface with several embedded devices.
* Achievements: A Java application to monitor temperature and send alerts via SMS and Yahoo! Instant Messenger as well as daily email reports. Used Java Swing for GUI control panel design.
-->

### Education

* *Master of Science*, University of California, Riverside. **GPA**: *3.92/4*
  * Designed and implemented sensor fusion algorithms for accelerometers, gyroscopes, and cameras, with applications targeted for smartphones, VR headsets, and driverless car navigation systems. 
    The algorithms, based on probabilistic models and statistical inference methods, are implemented and published in peer-reviewed conferences (ICRA, IROS).
* *Bachelor of Engineering*, National University of Singapore, Singapore. **GPA**: *4.42/5*

### Courseworks & Trainings

Lifelong learning and professional training after college.

* [Scala Seminar](/download/training/COC_Scala_Seminar.pdf).
* [Using](/download/training/COC_Using_Splunk.pdf) and [Searching](/download/training/COC_Searching_Splunk.pdf) with Splunk.
* [Chef Fundamentals](/download/training/COC_Chef.pdf).
* Amazon Web Services.
  * [AWS Technical Essentials](https://aws.amazon.com/training/course-descriptions/essentials/): [COC](/download/training/COC_AWS_Essentials.pdf)
  * [Developing on AWS](https://aws.amazon.com/training/course-descriptions/developing/): [COC](/download/training/COC_Developing_on_AWS.pdf)
  * [Architecting on AWS](https://aws.amazon.com/training/course-descriptions/architect/): [COC](/download/training/COC_Architecting_on_AWS.pdf)
* [Stanford OpenEdX: Database](/download/training/2014_Database_cert.pdf)

### Publications

* Estimator initialization in vision-aided inertial navigation with unknown camera-IMU calibration. IROS 2012. [PDF](/download/pubs/DongSi2012IROS.pdf)
  * Earlier work as Technical Report: [PDF](/download/pubs/2011_VIO_Init_TR.pdf)
* Consistency analysis for sliding-window visual odometry. ICRA 2012. [PDF](/download/pubs/DongSi2012ICRA.pdf)
  * Technical Report: [PDF](/download/pubs/ICRA12_TR.pdf)
* Motion tracking with fixed-lag smoothing: Algorithm and consistency analysis. ICRA 2011. [PDF](/download/pubs/DongSi2011ICRA.pdf)
  * Technical Report: [PDF](/download/pubs/ICRA11_TR.pdf)
* Technical Report: Application of the MSCKF algorithm on the Cheddar Gorge Wildcat Dataset. [PDF](/download/pubs/2010_MSCKF_Cheddar_Gorge.pdf)
* Extraction of shady roads using intrinsic colors on stereo camera. SMC 2008. [Technical report](/download/pubs/MEng.pdf)
* Robust extraction of shady roads for vision-based UGV navigation. IROS 2008. [Technical report](/download/pubs/MEng.pdf)

### Others

* [My only presence on Youtube](/blog/2011/02/07/optical-flow-demo/). 

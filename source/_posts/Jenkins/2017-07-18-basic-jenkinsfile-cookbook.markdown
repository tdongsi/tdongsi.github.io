---
layout: post
title: "Basic Jenkinsfile cookbook"
date: 2017-07-18 11:20:20 -0700
comments: true
categories: 
- Jenkins
- Groovy
---

This post shows how to customize standard Pipeline "steps" in Jenkinsfile besides their common usage.

<!--more-->

List of basic Jenkinsfile steps in this post:

* `checkout`/`git`
* `emailext`
* `findFiles`
* `input`
* `junit`
* `parameters`/`properties`
* `podTemplates`
* `sendSlack`
* `stash`/`unstash`
* `withCredentials`

### `checkout`/`git` step

`scm` is the global variable for the current commit AND branch AND repository of Jenkinsfile. 
`checkout scm` means checking out all other files with same version as the Jenkinsfile associated with running pipeline.
To check out another repository, you need to specify the paremeters to `checkout` step.

``` groovy Checkout from another Git repo
checkout([$class: 'GitSCM', branches: [[name: '*/master']],
     userRemoteConfigs: [[url: 'http://git-server/user/repository.git']]])

// From README file.
checkout scm: [$class: 'MercurialSCM', source: 'ssh://hg@bitbucket.org/user/repo', clean: true, credentialsId: '1234-5678-abcd'], poll: false
// If scm is the only parameter, you can omit its name, but Groovy syntax then requires parentheses around the value:
checkout([$class: 'MercurialSCM', source: 'ssh://hg@bitbucket.org/user/repo'])

// Short hand form for Git
git branch: 'develop', url: 'https://github.com/WtfJoke/Any.git'
```

Reference:

* [`git` step](https://jenkins.io/doc/pipeline/steps/git/#git-git)
* [`git` example](https://stackoverflow.com/questions/14843696/checkout-multiple-git-repos-into-same-jenkins-workspace)
* [`checkout` step](https://jenkins.io/doc/pipeline/steps/workflow-scm-step/#checkout-general-scm)
* [`checkout` README](https://github.com/jenkinsci/workflow-scm-step-plugin/blob/master/README.md)

### `emailext` step

To send email as HTML page, set content type to HTML and use content as `${FILE,path="email.html"}`.
In Jenkinsfile, the code should look like this:

``` groovy Send HTML report as email
emailext(
    subject: 'Deploy Notice',
    to: EMAIL_AUDIENCE,
    body: '${FILE,path="deploy_email.html"}',
    presendScript: '$DEFAULT_PRESEND_SCRIPT',
    replyTo: 'devops@my.company.com',
    mimeType: 'text/html'   // email as HTML
)
```

Note that it's single-quoted strings, not double-quoted, being used for `body` and `presendScript` parameters in the example code above.

Reference:

* [How to embed HTML report?](https://support.cloudbees.com/hc/en-us/articles/226237768-How-to-embed-html-report-in-email-body-using-Email-ext-plugin-)

### `findFiles` step

Doing in Bash:

``` groovy Doing in Bash
    sh '''
    for file in target/surefire-reports/*.txt;
    do
        echo $file >> testresult
    done
    cat testresult
    '''
    def result = readFile "testresult"
```

``` groovy Doing in Groovy
    def files = findFiles(glob: 'target/surefire-reports/*.txt')
    for file in files:
      echo """
      ${files[0].name} ${files[0].path} ${files[0].directory} 
      ${files[0].length} ${files[0].lastModified}
      """
```

Reference:

* [`findFiles` step](https://jenkins.io/doc/pipeline/steps/pipeline-utility-steps/)
* Related: `readFile`, `writeFile`.

### `input` step

Simple `input` step can be used to ask for approval to proceed.
For asking input from a list of multiple choices, you can use the advanced version of input.

``` groovy Input from list of choices
       sh "source scripts/findCL.sh > choiceLists.txt"
       def choiceOptions = readFile "${env.WORKSPACE}/choiceLists.txt"
       def choice = input(
       id: 'CHOICE_LIST', message:'Choose a CL' , parameters: [
        [$class: 'ChoiceParameterDefinition', name:'CHOICE_LIST_SELECTED', description:'Select one', choices:choiceOptions]
      ])
```

Reference:

* [`input` step](https://jenkins.io/doc/pipeline/steps/pipeline-input-step/)

### `junit` step

JUnit tests + PMD, FindBugs, CheckStyle. 
In Blue Ocean interface, these will be displayed in a separate tab.

``` groovy Related steps
stage('JUnit-Reports'){
    junit allowEmptyResults: true, testResults: '**/build/test-results/*.xml'
}

stage('FindBugs-Reports'){
    step([$class: 'FindBugsPublisher', canComputeNew: false, defaultEncoding: '', 
    excludePattern: '', healthy: '', includePattern: '', 
    pattern: '**/build/reports/findbugs/*.xml', unHealthy: ''])
}

stage('PMD-Reports'){
    step([$class: 'PmdPublisher', canComputeNew: false, defaultEncoding: '', 
    healthy: '', pattern: '**/build/reports/pmd/*.xml', unHealthy: ''])
}

stage('CheckStyle-Reports'){
    step([$class: 'CheckStylePublisher', canComputeNew: false, defaultEncoding: '', 
    healthy: '', pattern: '**/build/reports/checkstyle/*.xml', unHealthy: ''])
}
```

### `parameters`/`properties` step

`parameters` step adds certain job parameters for the overall pipeline job.

``` groovy parameters step in Declarative pipeline
pipeline {
    options {
        buildDiscarder(logRotator(numToKeepStr: '30', artifactNumToKeepStr: '30'))
        disableConcurrentBuilds()
    }
    agent { node { label 'aqueduct-agent' } }
    parameters {
        choice(name: 'ClusterName', choices: 'func\ninteg\nperf', description: 'Name of the cluster to test.')
    }
    stages {
        stage("Build") {
            steps {
                echo "Hello"
                ...
            }
        } //  end of stage
    }
    post {
        always {
            ...
        }
    }
}
```

In Scripted pipeline, its equivalent counterpart is `properties` step, as shown below.

``` groovy parameters step for Scripted pipeline
properties(
    [
        [
            $class  : 'jenkins.model.BuildDiscarderProperty',
            strategy: [
                $class      : 'LogRotator',
                numToKeepStr: '20'
            ]
        ],
        pipelineTriggers(
            [
                [
                    $class: 'hudson.triggers.TimerTrigger',
                    spec  : "H 8 * * *"
                ]
            ]
        )
    ]
)

node('agent') {
    stage('Checkout') {
        checkout scm
    }
    ...
}
```

In the Jenkins UI, this will be converted to configurations when you click on "View Configuration" for that job, as shown in screenshot below.
Note that the configurations in this page is read-only when using Jenkinsfile.
Any modifications made to the page will be ignored, leaving configurations set in Jenkinsfile final ("Infrastructure as Code").

{% img center /images/jenkins/properties.png 600 400 'View Configuration' 'Screenshot of View Configuration page'%}

Reference:

* [buildDiscarder](https://stackoverflow.com/questions/39542485/how-to-write-pipeline-to-discard-old-builds)
* [disableConcurrentBuilds](https://thepracticalsysadmin.com/limit-jenkins-multibranch-pipeline-builds/)

### `podTemplate` step

This step is used to specify a new pod template for running jobs on Kubernetes cluster.

``` groovy Kubernetes plugin
podTemplate(label:'base-agent', containers: [
    containerTemplate(name: 'maven', 
        image: 'docker.my/tdongsi/jenkins-agent:13',
        workingDir: '/home/jenkins',
        volumes: [hostPathVolume(mountPath: '/srv/jenkins', hostPath: '/usr/local/npm'),
        secretVolume(mountPath: '/etc/mount2', secretName: 'my-secret')],
        imagePullSecrets: 'sfregistry')
]) {
    node('base-agent') {
        stage('Checkout') {
            checkout scm
        }

        stage('main') {
            sh 'java -version'
            sh 'mvn -version'
            sh 'python -V'
        }
        
        input 'Finished with K8S pod?'
    }
}
```

Reference:

* [Kubernetes plugin](https://wiki.jenkins.io/display/JENKINS/Kubernetes+Plugin)
* [Tutorial](https://www.infoq.com/articles/scaling-docker-with-kubernetes)
* [Github repo](https://github.com/jenkinsci/kubernetes-plugin)
* [Pipeline steps](https://jenkins.io/doc/pipeline/steps/kubernetes/)

### `sendSlack` step

Standard Jenkinsfile for testing Slack

``` groovy Jenkinsfile
node('test-agent') {
    stage('Checkout') {
        checkout scm
    }
    
    stage('Main') {
        withCredentials([string(credentialsId: 'matrixsfdc-slack', variable: 'TOKEN')]) {
            slackSend ( teamDomain: 'matrixsfdc', channel: '#jenkins-pcloud', token: env.TOKEN,
                   baseUrl: 'https://matrixsfdc.slack.com/services/hooks/jenkins-ci/',
                   color: '#FFFF00', 
                   message: "STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"
                   )
        }
    }
    
    input 'Finished with K8S pod?'
}
```

### `stash`/`unstash` steps

`stash` step can be used to save a set of files, to be `unstash`ed later in the same build, generally for using in another workspace.
`unstash` will restore the files into the same relative locations as when they are `stash`ed.
If you want to change the base directory of the stashed files, you should wrap the `stash` steps in `dir` step.

We should use `stash`/`unstash` to avoid the common anti-pattern of copying files into some special, globally visible directory such as Jenkins home or one of its subdirectories.
Using such anti-pattern will make it hard to support many jobs for many users since, eventually, there will be some name clash and, subsequently, some convoluted naming of those files to avoid such name clashes.

Note that `stash` and `unstash` steps are designed for use with small files.
If the size is above 5 MB, we should consider an alternative such as Nexus/Artifactory for jar files, blob stores for images.

Example usage of `stash` and `unstash`:

``` groovy stash/unstash example
        stage('Stash') {  
            dir ('test') {
                sh '''
                    cd release_notes
                    touch deployment_ids.json
                    touch deployment_summary.json
                    ls -al
                '''

                stash name: 'deployment_ids', includes: 'release_notes/deployment_ids.json'
                stash name: 'deployment_summary', includes: 'release_notes/deployment_summary.json'
                
            } // end dir
        } // end stage 'Stash'

        stage('Check unstash') {
            dir('check') {
                unstash 'deployment_ids'

                sh 'tree -L 2'
            } 

            dir('check2') {
                unstash 'deployment_summary'

                sh 'tree -L 2'
            }
        }

        stage('Clean up') {
            sh 'tree -L 2'
            deleteDir()
        }
```

Example output:

``` plain Console output of the above stash/unstash example
[Pipeline] sh
04:14:04 + cd release_notes
04:14:04 + touch deployment_ids.json
04:14:04 + touch deployment_summary.json
04:14:04 + ls -al
04:14:04 total 128
04:14:04 drwxr-xr-x  5 jenkins cdrom  4096 Aug 18 04:14 .
04:14:04 drwxr-xr-x 26 jenkins cdrom  4096 Aug 18 04:14 ..
04:14:04 -rw-r--r--  1 jenkins cdrom     0 Aug 18 04:14 deployment_ids.json
04:14:04 -rw-r--r--  1 jenkins cdrom     0 Aug 18 04:14 deployment_summary.json
[Pipeline] stash
04:14:04 Stashed 1 file(s)
[Pipeline] stash
04:14:04 Stashed 1 file(s)
[Pipeline] }
[Pipeline] // dir
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Check unstash)
[Pipeline] dir
04:14:04 Running in /var/lib/jenkins/workspace/feature_test-23NL25SRLW3W6WXNVW2NXBADUXIYBTCBZAO5YRKVQPVT3NUSEOTQ/check
[Pipeline] {
[Pipeline] unstash
[Pipeline] sh
04:14:04 [check] Running shell script
04:14:05 + tree -L 2
04:14:05 .
04:14:05 └── release_notes
04:14:05     └── deployment_ids.json
04:14:05 
04:14:05 1 directory, 1 file
[Pipeline] }
[Pipeline] // dir
[Pipeline] dir
04:14:05 Running in /var/lib/jenkins/workspace/feature_test-23NL25SRLW3W6WXNVW2NXBADUXIYBTCBZAO5YRKVQPVT3NUSEOTQ/check2
[Pipeline] {
[Pipeline] unstash
[Pipeline] sh
04:14:05 [check2] Running shell script
04:14:05 + tree -L 2
04:14:05 .
04:14:05 └── release_notes
04:14:05     └── deployment_summary.json
04:14:05 
04:14:05 1 directory, 1 file
[Pipeline] }
[Pipeline] // dir
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Clean up)
[Pipeline] sh
04:14:05 [feature_test-23NL25SRLW3W6WXNVW2NXBADUXIYBTCBZAO5YRKVQPVT3NUSEOTQ] Running shell script
04:14:05 + tree -L 2
04:14:05 .
04:14:05 ├── check
04:14:05 │   └── release_notes
04:14:05 ├── check2
04:14:05 │   └── release_notes
04:14:05 ├── check2@tmp
04:14:05 ├── check@tmp
04:14:05 ├── Jenkinsfile
...
```

### `withCredentials` step

There are different variations of `withCredentials` step.
The most common ones are:

``` groovy Binding secret to username and password separately
node {
    withCredentials([usernamePassword(credentialsId: 'amazon', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
        // available as an env variable, but will be masked if you try to print it out any which way
        sh 'echo $PASSWORD'
        // also available as a Groovy variable—note double quotes for string interpolation
        echo "$USERNAME"
    }
}
```

``` groovy Binding secret to $username:$password
node {
  withCredentials([usernameColonPassword(credentialsId: 'mylogin', variable: 'USERPASS')]) {
    sh '''
      set +x
      curl -u $USERPASS https://private.server/ > output
    '''
  }
}
```

``` groovy Binding secret string to a variable
node {
  withCredentials([string(credentialsId: 'secretString', variable: 'MY_STRING')]) {
    sh '''
      echo $MY_STRING
    '''
  }
}
```

For secret file, the file will be passed into some secret location and that secret location will be bound to some variable.
If you want the secret files in specific locations, the workaround is to create symlinks to those secret files.

``` groovy Binding secret file
        withCredentials( [file(credentialsId: 'host-cert', variable: 'HOST_CERT'),
                        file(credentialsId: 'host-key', variable: 'HOST_KEY'),
                        file(credentialsId: 'cert-ca', variable: 'CERT_CA')
                        ]) 
        {
            sh """
                mkdir download
                ln -s ${env.HOST_CERT} download/hostcert.crt
                ln -s ${env.HOST_KEY} download/hostcert.key
                ln -s ${env.CERT_CA} download/ca.crt
            """

            // The Python script read those files download/*.* by default
            sh "python python/main.py"
        }
```

For "private key with passphrase" Credential type, `sshagent` is only usage that I know (credential ID is `jenkins_ssh_key` in this example):

``` groovy Binding private key with passphrase
node('my-agent'){
  stage 'Checkout'
  checkout scm

  if (env.BRANCH_NAME == 'master') {
    stage 'Commit'
    println "Pushing Jenkins Shared Library"

    sshagent(['jenkins_ssh_key']) {
      sh """
        git branch master
        git checkout master
        ssh-keyscan -H -p 12222 \${JENKINS_ADDR} >> ~/.ssh/known_hosts
        git remote add jenkins ssh://tdongsi@\${JENKINS_ADDR}:12222/workflowLibs.git
        git push --force jenkins master
      """
    }
  
  }
}
```

Reference:

* [Credentials Binding plugin](https://wiki.jenkins.io/display/JENKINS/Credentials+Binding+Plugin?focusedCommentId=80184884)

### References

* [Basic Jenkinsfile steps](https://jenkins.io/doc/pipeline/steps/)
* [Source code of Basic steps](https://github.com/jenkinsci/workflow-basic-steps-plugin/tree/master/src/main/java/org/jenkinsci/plugins/workflow/steps)

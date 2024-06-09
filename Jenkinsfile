#!groovy

@Library('pipelines-shared-library') _

import org.folio.Constants
import org.jenkinsci.plugins.workflow.libs.Library

properties([
  buildDiscarder(logRotator(numToKeepStr: '20')),
  disableConcurrentBuilds(),
//  pipelineTriggers([[$class: 'GitHubPushTrigger']]),
  parameters([
    //TODO change HELM_BRANCH value to origin/master before merge
    gitParameter(name: 'HELM_BRANCH', defaultValue: 'origin/master',
      description: 'GitHub branch to build an index from', branch: '', branchFilter: '.*', listSize: '0',
      quickFilterEnabled: true, selectedValue: 'DEFAULT', sortMode: 'ASCENDING', tagFilter: '*',
      type: 'GitParameterDefinition', useRepository: 'folio-helm-v2'),
    choice(name: 'HELM_NEXUS_REPOSITORY', choices: ['folio-helm-v2', 'folio-helm-v2-test'],
      description: 'Nexus repository of folio-helm chart'),
    booleanParam(name: 'INDEX_ALL', defaultValue: false, description: 'Run index for all charts in folio-helm-v2 repo'),
    folioParameters.refreshParameters()
  ])
])

if (params.REFRESH_PARAMETERS) {
  currentBuild.result = 'ABORTED'
  error('DRY RUN BUILD, PARAMETERS REFRESHED!')
}

currentBuild.displayName = "${params.HELM_NEXUS_REPOSITORY}.${env.BUILD_ID}"
String chartsRepositoryUrl = "${Constants.FOLIO_GITHUB_URL}/folio-helm-v2.git"
List chartsForIndex = []

ansiColor('xterm') {
  node('jenkins-agent-java17') {
    try {
      stage('Init') {
        println(currentBuild.getBuildCauses())
        sshagent(credentials: [Constants.GITHUB_CREDENTIALS_ID]) {
          checkout([
            $class           : 'GitSCM',
            branches         : [[name: params.HELM_BRANCH]],
            extensions       : scm.extensions + [[$class             : 'SubmoduleOption',
                                                  disableSubmodules  : false,
                                                  parentCredentials  : false,
                                                  recursiveSubmodules: true,
                                                  reference          : '',
                                                  trackingSubmodules : false]],
            userRemoteConfigs: [[url: chartsRepositoryUrl]]
          ])
          if (params.INDEX_ALL) {
            currentBuild.description = "Index all charts"
            chartsForIndex = sh(script: "ls -d charts/*", returnStdout: true).split('\\n')
          } else {
            chartsForIndex = sh(script: "git diff HEAD~1 --name-only -- charts/ | cut -d'/' -f1-2 | sort | uniq", returnStdout: true).split('\\n')
            chartsForIndex.remove("")
            currentBuild.description = "Triggered by Github"
          }
        }
      }
      stage("Package and index charts") {
        if (!chartsForIndex.isEmpty()) {
          folioHelm.withK8sClient {
            chartsForIndex.each {
              println("Pushing ${it} to repo Nexus...")
              withCredentials([usernamePassword(credentialsId: Constants.NEXUS_PUBLISH_CREDENTIALS_ID,
                usernameVariable: 'NEXUS_USERNAME', passwordVariable: 'NEXUS_PASSWORD'),
              ]) {
                sh """
                  CHART_PACKAGE="\$(helm package ${it} --dependency-update | cut -d":" -f2 | tr -d '[:space:]')"
                  curl -is -u "\$NEXUS_USERNAME:\$NEXUS_PASSWORD" "${Constants.NEXUS_BASE_URL}/${params.HELM_NEXUS_REPOSITORY}/" --upload-file "\$CHART_PACKAGE"
                """
              }
            }
          }
        } else {
          println("No charts for indexing")
        }
      }
    } catch (exception) {
      println(exception)
      error(exception.getMessage())
    } finally {
      stage('Cleanup') {
        cleanWs notFailBuild: true
      }
    }
  }
}

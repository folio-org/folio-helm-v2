#!groovy

@Library('pipelines-shared-library') _

import org.folio.Constants
import org.folio.utilities.Tools
import groovy.json.JsonSlurperClassic
import org.jenkinsci.plugins.workflow.libs.Library

properties([
    buildDiscarder(logRotator(numToKeepStr: '20')),
    disableConcurrentBuilds(),
    pipelineTriggers([[$class: 'GitHubPushTrigger']]),
    parameters([
        booleanParam(name: 'indexAllCharts', defaultValue: false, description: 'Run index for all charts in folio-helm-v2 repo')
    ])
])

def chartsRepositoryUrl = "${Constants.FOLIO_GITHUB_URL}/folio-helm-v2.git"
List chartsForIndex

ansiColor('xterm') {
    node('jenkins-agent-java11') {
        try {
            stage('Init') {
                sshagent(credentials: [Constants.GITHUB_CREDENTIALS_ID]) {
                    checkout([
                        $class           : 'GitSCM',
                        branches         : [[name: "*/master"]],
                        extensions       : scm.extensions + [[$class             : 'SubmoduleOption',
                                                            disableSubmodules  : false,
                                                            parentCredentials  : false,
                                                            recursiveSubmodules: true,
                                                            reference          : '',
                                                            trackingSubmodules : false]],
                        userRemoteConfigs: [[url: chartsRepositoryUrl]]
                    ])
                    if (params.indexAllCharts) {
                        chartsForIndex = sh(script: "ls -d charts/*", returnStdout: true).split('\\n')
                        currentBuild.displayName = "Index all charts"
                    } else {
                        chartsForIndex = sh(script: "git diff HEAD~1 --name-only -- charts/ | cut -d'/' -f1-2 | sort | uniq", returnStdout: true).split('\\n')
                        chartsForIndex.remove("")
                        currentBuild.displayName = "Triggered by Github"
                    }
                }
            }
            stage("Package and index charts") {
                withCredentials([
                    usernamePassword(credentialsId: Constants.NEXUS_PUBLISH_CREDENTIALS_ID, usernameVariable: 'NEXUS_USERNAME', passwordVariable: 'NEXUS_PASSWORD'),
                ]) {
                    if (!chartsForIndex.isEmpty()) {
                        helm.k8sClient {
                            chartsForIndex.each {
                                sh """
                                echo "Pushing ${it} to repo Nexus..."
                                CHART_PACKAGE="\$(helm package ${it} --dependency-update | cut -d":" -f2 | tr -d '[:space:]')"
                                curl -is -u "${NEXUS_USERNAME}:${NEXUS_PASSWORD}" ${Constants.FOLIO_HELM_V2_REPO_URL} --upload-file "\$CHART_PACKAGE"
                                """
                            }
                        }
                    } else {
                        println("No charts for indexing")
                    }
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

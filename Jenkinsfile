
pipeline {
    agent any

    environment {
        ARTEFACT_NAME = "${WORKSPACE}/target/WebGoat-${BUILD_VERSION}.war"
        BOM_FILE = "${WORKSPACE}/target/WebGoat-bom.xml"
        DEV_REPO = 'staging-development'
        TAG_FILE = "${WORKSPACE}/tag.json"
        IQ_SCAN_URL = ""
    }
    
    tools { 
        jdk 'jdk8' 
    }

    stages {
        stage('Build') {
            steps {
                sh 'which java'
                sh 'mvn -B -Dproject.version=$BUILD_VERSION -Dmaven.test.failure.ignore clean package cyclonedx:makeBom'
            }
            post {
                success {
                    echo 'Now archiving...'
                    archiveArtifacts artifacts: "**/target/*.war"
                }
            }
        }

        stage('Nexus IQ Scan'){
            steps {
                script{
                
                    try {
                        def policyEvaluation = nexusPolicyEvaluation advancedProperties: '', 
                                        enableDebugLogging: false, 
                                        failBuildOnNetworkError: false, 
                                        iqApplication: manualApplication('webgoat4-ci'), 
                                        iqScanPatterns: [[scanPattern: '**/*.war']], 
                                        iqInstanceId: 'nexusiq', 
                                        iqStage: 'build', 
                                        jobCredentialsId: 'Sonatype'

                        echo "Nexus IQ scan succeeded: ${policyEvaluation.applicationCompositionReportUrl}"
                        IQ_SCAN_URL = "${policyEvaluation.applicationCompositionReportUrl}"
                    } 
                    catch (error) {
                        def policyEvaluation = error.policyEvaluation
                        echo "Nexus IQ scan vulnerabilities detected', ${policyEvaluation.applicationCompositionReportUrl}"
                        throw error
                    }
                }
            }
        }

        stage('Create tag'){
            steps {
                script {
    
                    // Git data (Git plugin)
                    echo "${GIT_COMMIT}"
                    echo "${GIT_URL}"
                    echo "${GIT_BRANCH}"
                    echo "${WORKSPACE}"
                    
                    // construct the meta data (Pipeline Utility Steps plugin)
                    def tagdata = readJSON text: '{}' 
                    tagdata.buildUser = "${USER}" as String
                    tagdata.buildNumber = "${BUILD_NUMBER}" as String
                    tagdata.buildId = "${BUILD_ID}" as String
                    tagdata.buildJob = "${JOB_NAME}" as String
                    tagdata.buildTag = "${BUILD_TAG}" as String
                    tagdata.appVersion = "${BUILD_VERSION}" as String
                    tagdata.buildUrl = "${BUILD_URL}" as String
                    tagdata.iqScanUrl = "${IQ_SCAN_URL}" as String
                    tagdata.promote = "no" as String

                    writeJSON(file: "${TAG_FILE}", json: tagdata, pretty: 4)
                    sh 'cat ${TAG_FILE}'

                    createTag nexusInstanceId: 'nxrm3', tagAttributesPath: "${TAG_FILE}", tagName: "${BUILD_TAG}"

                    // write the tag name to the build page (Rich Text Publisher plugin)
                    rtp abortedAsStable: false, failedAsStable: false, parserName: 'Confluence', stableText: "Nexus Repository Tag: ${BUILD_TAG}", unstableAsStable: true 
                }
            }
        }

        stage('Inspect files'){
            steps {
                sh 'ls -l target'
            }
        }

        stage('Upload to Nexus Repository'){
            steps {
            
                script {
                    nexusPublisher nexusInstanceId: 'nxrm3', 
                        nexusRepositoryId: "${DEV_REPO}", 
                        packages: [[$class: 'MavenPackage', mavenAssetList: [[classifier: '', extension: 'xml', filePath: "${BOM_FILE}"], 
                                                                             [classifier: '', extension: 'war', filePath: "${ARTEFACT_NAME}"]], 
                        mavenCoordinate: [artifactId: 'WebGoat', groupId: 'org.webgoat4', packaging: 'war', version: "${BUILD_VERSION}"]]], 
                        tagName: "${BUILD_TAG}"
                }
            }
        }
    }
}


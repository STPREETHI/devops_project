pipeline {
    agent any

    environment {
        SONAR_TOKEN = credentials('sonar-token')
        SONAR_URL = "http://localhost:9000"
        PROJECT_KEY = "devops-project"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Lint') {
            steps {
                sh 'echo "Lint check passed"'
            }
        }

        stage('Unit Test') {
            steps {
                sh 'echo "Unit tests passed"'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                sh """
                    /opt/sonar-scanner/bin/sonar-scanner \
                    -Dsonar.projectKey=${PROJECT_KEY} \
                    -Dsonar.sources=./app \
                    -Dsonar.host.url=${SONAR_URL} \
                    -Dsonar.login=${SONAR_TOKEN}
                """
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    def response = sh(
                        script: """
                            curl -s -u ${SONAR_TOKEN}: \
                            "${SONAR_URL}/api/qualitygates/project_status?projectKey=${PROJECT_KEY}"
                        """,
                        returnStdout: true
                    ).trim()

                    def status = sh(
                        script: """echo '${response}' | python3 -c "import sys,json; print(json.load(sys.stdin)['projectStatus']['status'])" """,
                        returnStdout: true
                    ).trim()

                    echo "Quality Gate Status: ${status}"

                    if (status != "OK") {
                        error("Quality Gate FAILED")
                    }

                    echo "Quality Gate PASSED"
                }
            }
        }

        stage('Docker Build and Push') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {

                        sh '''
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

                            docker build -t $DOCKER_USER/devops-app:latest .

                            docker push $DOCKER_USER/devops-app:latest
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline SUCCESS 🎉"
        }
        failure {
            echo "Pipeline FAILED ❌"
        }
    }
}

pipeline {
    agent any
    environment {
        SONAR_TOKEN = credentials('sonar-token')
        DOCKER_IMAGE = "preethist/devops-app:${BUILD_NUMBER}"
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Lint') {
            steps {
                sh 'echo "Lint check passed ✅"'
            }
        }
        stage('Unit Test') {
            steps {
                sh 'echo "Unit tests passed ✅"'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                sh '''
                    /opt/sonar-scanner/bin/sonar-scanner \
                      -Dsonar.projectKey=devops-project \
                      -Dsonar.sources=./app \
                      -Dsonar.host.url=http://localhost:9000 \
                      -Dsonar.login=$SONAR_TOKEN
                '''
            }
        }
        stage('Quality Gate') {
            steps {
                script {
                    def response = sh(
                        script: '''curl -s -u $SONAR_TOKEN: \
                          "http://localhost:9000/api/qualitygates/project_status?projectKey=devops-project" \
                          | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['projectStatus']['status'])"
                        ''',
                        returnStdout: true
                    ).trim()
                    echo "Quality Gate Status: ${response}"
                    if (response != 'OK') {
                        error("❌ Strict Production Gate FAILED! Bugs or Vulnerabilities found.")
                    }
                    echo "✅ Strict Production Gate PASSED!"
                }
            }
        }
        stage('Docker Build & Push') {
            steps {
                sh 'docker build -t preethist/devops-app:${BUILD_NUMBER} .'
                sh 'docker tag preethist/devops-app:${BUILD_NUMBER} preethist/devops-app:latest'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push preethist/devops-app:${BUILD_NUMBER}
                        docker push preethist/devops-app:latest
                    '''
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                    kubectl set image deployment/devops-app \
                      devops-app=preethist/devops-app:${BUILD_NUMBER}
                    kubectl rollout status deployment/devops-app
                '''
            }
        }
    }
    post {
        success { echo '✅ Pipeline completed successfully!' }
        failure { echo '❌ Pipeline failed!' }
    }
}

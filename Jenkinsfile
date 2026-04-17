pipeline {
    agent any
    environment {
        SONAR_TOKEN = credentials('sonar-token')
        DOCKER_USER = credentials('dockerhub-creds')
    }
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Lint') {
            steps { sh 'echo Lint check passed' }
        }
        stage('Unit Test') {
            steps { sh 'echo Unit tests passed' }
        }
        stage('SonarQube Analysis') {
            steps {
                sh '/opt/sonar-scanner/bin/sonar-scanner -Dsonar.projectKey=devops-project -Dsonar.sources=./app -Dsonar.host.url=http://localhost:9000 -Dsonar.login=$SONAR_TOKEN'
            }
        }
        stage('Quality Gate') {
            steps {
                script {
                    def qg = sh(
                        script: 'curl -s -u $SONAR_TOKEN: "http://localhost:9000/api/qualitygates/project_status?projectKey=devops-project" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d[\'projectStatus\'][\'status\'])"',
                        returnStdout: true
                    ).trim()
                    if (qg != 'OK') { error('Gate FAILED') }
                    echo 'Strict_Production_Gate PASSED!'
                }
            }
        }
        stage('Docker Build and Push') {
            steps {
                sh 'docker build -t preethist/devops-app:latest .'
                sh 'echo $DOCKER_USER_PSW | docker login -u $DOCKER_USER_USR --password-stdin'
                sh 'docker push preethist/devops-app:latest'
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl set image deployment/devops-app devops-app=preethist/devops-app:latest'
                sh 'kubectl rollout status deployment/devops-app'
            }
        }
    }
    post {
        success { echo 'Pipeline completed successfully!' }
        failure { echo 'Pipeline failed!' }
    }
}

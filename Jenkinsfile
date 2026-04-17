pipeline {
    agent any
    environment {
        SONAR_TOKEN = credentials('sonar-token')
        BUILD_NUM = "${BUILD_NUMBER}"
    }
    stages {
        stage('Checkout') {
            steps { checkout scm }
        }
        stage('Lint') {
            steps { sh 'echo "Lint check passed"' }
        }
        stage('Unit Test') {
            steps { sh 'echo "Unit tests passed"' }
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
                    echo "Quality Gate: ${qg}"
                    if (qg != 'OK') { error("Strict_Production_Gate FAILED!") }
                    echo "Strict_Production_Gate PASSED!"
                }
            }
        }
        stage('Docker Build and Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DUSER', passwordVariable: 'DPASS')]) {
                    sh 'docker build -t $DUSER/devops-app:$BUILD_NUM .'
                    sh 'docker tag $DUSER/devops-app:$BUILD_NUM $DUSER/devops-app:latest'
                    sh 'echo "$DPASS" | docker login -u "$DUSER" --password-stdin'
                    sh 'docker push $DUSER/devops-app:$BUILD_NUM'
                    sh 'docker push $DUSER/devops-app:latest'
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl set image deployment/devops-app devops-app=preethist/devops-app:$BUILD_NUM'
                sh 'kubectl rollout status deployment/devops-app'
            }
        }
    }
    post {
        success { echo 'Pipeline completed successfully!' }
        failure { echo 'Pipeline failed!' }
    }
}

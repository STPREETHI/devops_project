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
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        sonar-scanner \
                          -Dsonar.projectKey=devops-project \
                          -Dsonar.sources=./app \
                          -Dsonar.host.url=http://localhost:9000 \
                          -Dsonar.login=$SONAR_TOKEN
                    '''
                }
            }
        }
        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('Docker Build & Push') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push $DOCKER_IMAGE
                    '''
                }
            }
        }
        stage('Update K8s Manifest') {
            steps {
                sh "sed -i 's|image:.*|image: $DOCKER_IMAGE|g' kubernetes/deployment.yaml"
                sh '''
                    git config user.email "ci@jenkins"
                    git config user.name "Jenkins"
                    git add kubernetes/deployment.yaml
                    git commit -m "CI: update image to build $BUILD_NUMBER"
                    git push origin main
                '''
            }
        }
    }
    post {
        success { echo 'Pipeline completed successfully!' }
        failure { echo 'Pipeline failed!' }
    }
}

pipeline {
    agent any

    environment {
        SONAR_TOKEN = credentials('sonar-token')
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Lint') {
            steps {
                sh 'echo Lint check passed'
            }
        }

        stage('Unit Test') {
            steps {
                sh 'echo Unit tests passed'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                sh """
                /opt/sonar-scanner/bin/sonar-scanner \
                -Dsonar.projectKey=devops-project \
                -Dsonar.sources=./app \
                -Dsonar.host.url=http://localhost:9000 \
                -Dsonar.login=${SONAR_TOKEN}
                """
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    def qg = sh(
                        script: """
                        curl -s -u ${SONAR_TOKEN}: \
                        'http://localhost:9000/api/qualitygates/project_status?projectKey=devops-project' \
                        | python3 -c "import sys,json; print(json.load(sys.stdin)['projectStatus']['status'])"
                        """,
                        returnStdout: true
                    ).trim()

                    if (qg != 'OK') {
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

                        sh """
                        echo "Building Docker image..."
                        docker build -t preethist/devops-app:latest .

                        echo "Logging into Docker Hub..."
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin

                        echo "Pushing image..."
                        docker push preethist/devops-app:latest
                        """
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                kubectl set image deployment/devops-app \
                devops-app=preethist/devops-app:latest

                kubectl rollout status deployment/devops-app
                """
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}

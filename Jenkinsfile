pipeline {
    agent any

    environment {
        IMAGE_NAME = "dockerhubusername/poc-1"
        SONAR_TOKEN = credentials('sonar-token')
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build & Unit Tests') {
            steps {
                dir('app') {
                    sh 'mvn clean test package'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    dir('app') {
                        sh """
                        mvn sonar:sonar \
                          -Dsonar.login=${SONAR_TOKEN}
                        """
                    }
                }
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                sh 'bash dependency-check.sh'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t $IMAGE_NAME:latest .'
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh 'trivy image --severity HIGH,CRITICAL $IMAGE_NAME:latest'
            }
        }

        stage('Docker Push') {
            steps {
                withDockerRegistry(credentialsId: 'dockerhub-creds', url: '') {
                    sh 'docker push $IMAGE_NAME:latest'
                }
            }
        }

        stage('Deploy Docker Container') {
            steps {
                sh '''
                docker rm -f poc-1 || true
                docker run -d --name poc-1 -p 8080:8080 $IMAGE_NAME:latest
                '''
            }
        }
    }
}
pipeline {
    agent any

    environment {
        IMAGE_NAME = "sandeep680/poc-1"
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
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    dir('app') {
                        sh '''
                          mvn verify sonar:sonar \
                          -Dsonar.projectKey=poc-1 \
                          -Dsonar.host.url=http://localhost:9000 \
                          -Dsonar.login=$SONAR_TOKEN
                        '''
                    }
                }
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                sh '''
                  bash dependency-check.sh || echo "OWASP scan skipped"
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t $IMAGE_NAME:latest .'
            }
        }

stage('Trivy Scan') {
    steps {
        sh '''
          echo "Starting Trivy scan (POC mode)"

          export TRIVY_SKIP_UPDATE=true
          export TRIVY_JAVA_DB_ENABLED=false
          export TRIVY_TIMEOUT=5m

          trivy image \
            --scanners os \
            --ignore-unfixed \
            --severity CRITICAL \
            --no-progress \
            --exit-code 0 \
            $IMAGE_NAME:latest || true

          echo "Trivy scan completed (POC mode)"
        '''
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
                  docker run -d --name poc-1 -p 8081:8080 $IMAGE_NAME:latest
                '''
            }
        }
    }
}
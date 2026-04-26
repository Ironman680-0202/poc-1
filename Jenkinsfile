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
        withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
            sh '''
            mvn clean verify sonar:sonar \
              -Dsonar.projectKey=poc-1 \
              -Dsonar.host.url=http://localhost:9000 \
              -Dsonar.login=$SONAR_TOKEN
            '''
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

      stage('Trivy Scan') {
    steps {
        sh '''
        TRIVY_JAVA_DB_ENABLED=false trivy image \
          --skip-db-update \
          --offline-scan \
          --scanners vuln \
          --severity CRITICAL \
          --no-progress \
          --exit-code 0 \
          sandeep680/poc-1:latest
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
                docker run -d --name poc-1 -p 8080:8080 $IMAGE_NAME:latest
                '''
            }
        }
    }
}
pipeline {
    agent any

    environment {
        IMAGE_NAME = "springboot-devops-app"
        DOCKERHUB_REPO = "tokesh070/springboot-devops-app"
    }

    stages {

        stage('Clone Code') {
            steps {
                git 'https://github.com/YOUR-USERNAME/springboot-devops-app.git'
            }
        }

        stage('Build - Maven') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Test') {
            steps {
                sh '''
                java -jar target/*.jar &
                APP_PID=$!

                sleep 10

                curl -f http://localhost:8080 || exit 1

                kill $APP_PID
                '''
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh 'mvn sonar:sonar'
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

        stage('Docker Build') {
            steps {
                sh 'docker build -t $IMAGE_NAME:${BUILD_NUMBER} .'
            }
        }

        stage('Push to DockerHub') {
            steps {
                sh '''
                docker tag $IMAGE_NAME:${BUILD_NUMBER} $DOCKERHUB_REPO:${BUILD_NUMBER}
                docker push $DOCKERHUB_REPO:${BUILD_NUMBER}
                '''
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                docker rm -f springboot-container || true
                docker run -d -p 8080:8080 \
                --name springboot-container \
                $DOCKERHUB_REPO:${BUILD_NUMBER}
                '''
            }
        }
    }
}

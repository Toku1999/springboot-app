pipeline {
    agent any

    environment {
        IMAGE_NAME = "springboot-devops-app"
        DOCKERHUB_REPO = "tokesh070/springboot-devops-app"
    }

    tools {
        maven 'Maven'
    }

    stages {

        stage('Clone Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/tokesh070/springboot-devops-app.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                sh '''
                java -jar target/*.jar &
                APP_PID=$!

                for i in {1..20}; do
                    curl -s http://localhost:8080 && break
                    sleep 2
                done

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
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin

                    docker tag $IMAGE_NAME:${BUILD_NUMBER} $DOCKERHUB_REPO:${BUILD_NUMBER}
                    docker push $DOCKERHUB_REPO:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                docker rm -f springboot-container || true

                docker run -d -p 8081:8080 \
                --name springboot-container \
                $DOCKERHUB_REPO:${BUILD_NUMBER}
                '''
            }
        }
    }
}

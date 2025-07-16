pipeline {
  agent any

  environment {
    IMAGE_NAME = "192.168.1.66:8082/foodapp/food-app"
    REGISTRY_URL = "http://192.168.1.66:8082"
  }

  stages {

    stage('Clone Code') {
      steps {
        checkout([$class: 'GitSCM',
          branches: [[name: '*/main']],
          userRemoteConfigs: [[
            url: 'https://github.com/Kamal4561/CICD.git',
            credentialsId: 'github-creds'
          ]]
        ])
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          docker.build("${IMAGE_NAME}")
        }
      }
    }

    stage('Push to Harbor') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'harbor-id', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
          script {
            docker.withRegistry("${REGISTRY_URL}", 'harbor-id') {
              docker.image("${IMAGE_NAME}").push("latest")
            }
          }
        }
      }
    }

    stage('Deploy Container') {
      steps {
        script {
          sh '''
            docker stop food-app || true
            docker rm food-app || true
            docker run -d --name food-app -p 8126:8000 ${IMAGE_NAME}:latest
          '''
        }
      }
    }
  }
}

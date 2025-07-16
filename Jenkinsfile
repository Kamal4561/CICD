pipeline {
  agent any

  environment {
    IMAGE_NAME = "foodapp/food-app"
    REGISTRY_URL = "192.168.1.66:8082"
    FULL_IMAGE_NAME = "${REGISTRY_URL}/${IMAGE_NAME}:latest"
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

    stage('Tag and Push to Harbor') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'harbor-id', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
          script {
            sh """
              echo "$PASS" | docker login ${REGISTRY_URL} -u "$USER" --password-stdin
              docker tag ${IMAGE_NAME} ${FULL_IMAGE_NAME}
              docker push ${FULL_IMAGE_NAME}
            """
          }
        }
      }
    }

    stage('Deploy Container') {
      steps {
        script {
          sh """
            docker stop food-app || true
            docker rm food-app || true
            docker run -d --name food-app -p 8126:8000 ${FULL_IMAGE_NAME}
          """
        }
      }
    }
  }
}

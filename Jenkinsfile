pipeline {
  agent any

  environment {
    IMAGE_NAME = "192.168.1.66:8082/foodapp/food-app"
    SONARQUBE_ENV = "SonarQube"
    REGISTRY_URL = "http://192.168.1.66:8082"
  }

  stages {

    stage('Clone Code') {
      steps {
        checkout([$class: 'GitSCM',
          branches: [[name: '*/main']],
          userRemoteConfigs: [[
            url: 'https://github.com/Kamal4561/CICD.git',
            credentialsId: 'git-creds'
          ]]
        ])
      }
    }

    stage('SonarQube Scan') {
      steps {
        withSonarQubeEnv("${SONARQUBE_ENV}") {
          script {
            def scannerHome = tool 'SonarScanner'
            sh """
              ${scannerHome}/bin/sonar-scanner \
                -Dsonar.projectKey=FOOD_APP \
                -Dsonar.sources=. \
                -Dsonar.host.url=http://192.168.1.66:9000
            """
          }
        }
      }
    }

    stage("Quality Gate") {
      steps {
        timeout(time: 1, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
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

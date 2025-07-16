pipeline {
  agent any
  environment {
    IMAGE_NAME = "colorweb/myapp"
    REGISTRY_URL = "192.168.1.102"
    SONARQUBE_ENV = "SonarQube"
  }
    stages {
    stage('Clone Code') {
      steps {
        checkout([$class: 'GitSCM',
          branches: [[name: '*/master']],
          userRemoteConfigs: [[
            url: 'http://192.168.1.101:7990/scm/cicd/color_web.git',
            credentialsId: '23ff5c48-819a-4144-ade8-a1dab123f77a'
          ]]
        ])
      }
    }

      stage('SonarQube') {
    steps {
      withSonarQubeEnv("${SONARQUBE_ENV}") {
        script {
          def scannerHome = tool 'SonarScanner'
          sh """
            ${scannerHome}/bin/sonar-scanner \
              -Dsonar.projectKey=COLOR_WEB \
              -Dsonar.sources=. \
              -Dsonar.java.binaries=target/ \
              -Dsonar.host.url=http://192.168.1.102:9001
          """
        }
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
       stage('Build and Push Image') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'kamal', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
          script {
            docker.withRegistry("http://${REGISTRY_URL}", 'kamal') {
              docker.build("${IMAGE_NAME}").push("latest")
            }
          }
        }
      }
    }

  stage('Run Docker Container') {
      steps {
        script {
          sh '''
            # Stop and remove existing container if it exists
            docker stop myapp || true
            docker rm myapp || true

            # Run the new container with port mapping
            docker run -d --name myapp -p 8126:8000 colorweb/myapp:latest
          '''
        }
      }
    }

  }
}

pipeline {
  agent { label 'ruby' }
  stages {
    stage('Setup') {
      steps {
        sh label: 'Checking RuboCop Version', script: 'rubocop -v'
        sh label: 'Checking Docker Version', script: 'docker -v'
      }
    }
    stage('RuboCop') {
      steps {
        sh label: 'Running RuboCop', script: 'rubocop'
      }
    }
    stage('Build Docker Image') {
      when {
        expression { fileExists('./Dockerfile') }
        branch 'master'
      }
      steps {
        echo 'Dockerfile exists and we have pushed to master. Exporting image...' 
        sh label: 'Build Dockerfile', script: 'docker build -t haikubot .'
      }
    }
    stage('Archive Docker Image') {
      when {
        expression { fileExists('./Dockerfile') }
        branch 'master'
      }
      steps {
        sh label: 'Pull Docker image into tar', script: 'docker image save -o ./haikubot.tar haikubot:latest'
        archiveArtifacts artifacts: 'haikubot.tar'
      }
    }
  }
  post {
    always {
      echo 'Cleaning up...'
      script {
        try {
          sh label: 'Delete Docker image', script: 'docker image rm haikubot'
          sh label: 'Delete Ruby Docker image', script: 'docker image rm ruby'
        } catch(err) {
          echo "Docker image doesn't exist; let's continue."
        }
      echo 'Complete.'
      }
    }
  }
}

pipeline {
  agent { label 'ruby' }
  environment{
    DOCKERFILE = fileExists 'Dockerfile'
  }
  stages {
    stage('Setup') {
      steps {
        sh label: 'Checking RuboCop Version', script: 'rubocop -v'
      }
    }
    stage('RuboCop') {
      steps {
        sh label: 'Running RuboCop', script: 'rubocop'
      }
    }
    stage('Build Docker Dummy') {
      when {
        expression { DOCKERFILE == 'true' }
        branch 'master'
      }
      steps {
        echo 'Dockerfile exists and we pushed to master.' 
      }
    }
  }
}
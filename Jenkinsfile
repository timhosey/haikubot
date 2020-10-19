pipeline {
  agent { label 'ruby' }
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
        // expression { fileExists('./Dockerfile') }
        branch 'master'
      }
      steps {
        echo 'Dockerfile exists and we pushed to master.' 
      }
    }
  }
}

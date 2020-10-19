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
        branch 'master'
      }
      steps {
        def exists = fileExists 'Dockerfile'
        if (exists) {
          echo 'Dockerfile exists and we pushed to master.' 
        } else {
          abort 'Dockerfile is missing so we\'re killing the run.'
        }
      }
    }
  }
}
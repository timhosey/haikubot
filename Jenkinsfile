pipeline {
  agent { label 'ruby' }
  stages {
    stage('Setup') {
      steps {
        sh 'rubocop -v'
      }
    }
    stage('RuboCop') {
      steps {
        sh 'rubocop'
      }
    }
  }
}
pipeline {
  agent { label 'ruby' }
  stages {
    stage('Setup') {
      steps {
        sh 'gem install rubocop'
      }
    }
    stage('RuboCop') {
      steps {
        sh 'rubocop'
      }
    }
  }
}
pipeline {
  agent { label 'ruby' }
  stages {
    stage('Setup') {
      steps {
        sh 'sudo gem install rubocop'
      }
    }
    stage('RuboCop') {
      steps {
        sh 'rubocop'
      }
    }
  }
}
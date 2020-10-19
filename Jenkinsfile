pipeline {
  agent { label 'ruby' }
  stages {
    stage('Setup') {
      sh 'gem install rubocop'
    }
    stage('RuboCop') {
      sh 'rubocop'
    }
  }
}
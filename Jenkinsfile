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
    stage('Build Docker Dummy') {
      when {
        expression { fileExists('./Dockerfile') }
        branch 'master'
      }
      steps {
        echo 'Dockerfile exists and we have pushed to master. Exporting image...' 
        sh label: 'Build Dockerfile', script: 'docker build --output type=tar,dest=haikubot_image.tar .'
        archiveArtifacts artifacts: '*.tar'
      }
    }
  }
}

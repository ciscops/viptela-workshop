pipeline {
    agent { dockerfile true }
    options {
      disableConcurrentBuilds()
    }
    environment {
        VIRL_USERNAME = credentials('cpn-virl-username')
        VIRL_PASSWORD = credentials('cpn-virl-password')
        VIRL_HOST = credentials('cpn-virl-host')
    }
    stages {
        stage('Build Workshop') {
           steps {
                echo 'Running build.yml...'
                sh 'ansible-playbook build.yml'
           }
        }
        stage('Configure Workshop') {
           steps {
                echo 'Running configure.yml...'
                sh 'ansible-playbook configure.yml'
           }
        }
        stage('Clean Workshop') {
           steps {
                echo 'Running clean.yml...'
                sh 'ansible-playbook clean.yml'
           }
        }
    }
}

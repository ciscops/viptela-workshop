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
                ansiblePlaybook colorized: true, disableHostKeyChecking: true, playbook: 'build.yml'
           }
        }
        stage('Configure Workshop') {
           steps {
                echo 'Running configure.yml...'
                ansiblePlaybook colorized: true, disableHostKeyChecking: true, playbook: 'configure.yml'
           }
        }
        stage('Clean Workshop') {
           steps {
                echo 'Running clean.yml...'
                ansiblePlaybook colorized: true, disableHostKeyChecking: true, playbook: 'clean.yml'
           }
        }
    }
}

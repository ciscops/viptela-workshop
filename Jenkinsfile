pipeline {
    agent {
        dockerfile {
            filename 'Dockerfile'
            args  '-v /etc/passwd:/etc/passwd'
        }
    }
    options {
      disableConcurrentBuilds()
    }
    environment {
        VIRL_USERNAME = credentials('cpn-virl-username')
        VIRL_PASSWORD = credentials('cpn-virl-password')
        VIRL_HOST = credentials('cpn-virl-host')
        VIPTELA_ORG = credentials('viptela-org')
    }
    stages {
        stage('Prepare Workspace') {
            steps {
                echo 'Retrieve viptela_serial_file.viptela...'
                sh 'mkdir licenses'
                withCredentials([file(credentialsId: 'viptela-serial-file', variable: 'viptela-serial-file')]) {
                    sh "cp \$viptela-serial-file licenses/viptela_serial_file.viptela"
                }
            }
        }
        stage('Build Workshop') {
           steps {
                echo 'Running build.yml...'
                ansiblePlaybook disableHostKeyChecking: true, extras: "-e virl_tag=jenkins", playbook: 'build.yml'
           }
        }
       stage('Configure Workshop') {
           steps {
                echo 'Running configure.yml...'
                ansiblePlaybook disableHostKeyChecking: true, extras: '-e virl_tag=jenkins -e organization_name="${VIPTELA_ORG}"', playbook: 'configure.yml'
           }
        }
    }
    post {
        always {
            ansiblePlaybook disableHostKeyChecking: true, extras: "-e virl_tag=jenkins", playbook: 'clean.yml'
            cleanWs()
        }
    }
}

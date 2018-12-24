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
        stage('Build Workshop') {
           steps {
                echo 'Running build.yml...'
                ansiblePlaybook disableHostKeyChecking: true, extras: "-e virl_tag=jenkins", playbook: 'build.yml'
           }
        }
        stage('Configure Workshop') {
           steps {
                echo 'Running configure.yml...'
                withCredentials([file(credentialsId: 'viptela_serial_file.viptela', variable: 'viptela-serial-file')]) {
                    ansiblePlaybook disableHostKeyChecking: true, extras: '-e virl_tag=jenkins -e organization_name="${VIPTELA_ORG}" -e serial_number_file=$viptela-serial-file', playbook: 'configure.yml'
                }
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

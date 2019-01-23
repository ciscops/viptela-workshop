pipeline {
    agent {
        dockerfile {
            filename 'Dockerfile'
            args  '-v /etc/passwd:/etc/passwd'
        }
    }
    options {
      disableConcurrentBuilds()
      lock resource: 'viptela-workshop-testbed'
    }
    environment {
        VIRL_USERNAME = credentials('cpn-virl-username')
        VIRL_PASSWORD = credentials('cpn-virl-password')
        VIRL_HOST = credentials('cpn-virl-host')
        VIPTELA_ORG = credentials('viptela-org')
        HOME = "${WORKSPACE}"
        DEFAULT_LOCAL_TMP = "${WORKSPACE}/ansible"
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
                echo 'Configure Viptela Control Plane...'
                withCredentials([file(credentialsId: 'viptela-serial-file', variable: 'VIPTELA_SERIAL_FILE')]) {
                    ansiblePlaybook disableHostKeyChecking: true, extras: '-e virl_tag=jenkins -e \'organization_name="${VIPTELA_ORG}"\' -e serial_number_file=${VIPTELA_SERIAL_FILE} -e viptela_cert_dir=${WORKSPACE}/myCA', tags: 'control', playbook: 'configure.yml'
                }
           steps {
                echo 'Check Viptela Control Plane...'
                withCredentials([file(credentialsId: 'viptela-serial-file', variable: 'VIPTELA_SERIAL_FILE')]) {
                    ansiblePlaybook disableHostKeyChecking: true, extras: '-e virl_tag=jenkins -e \'organization_name="${VIPTELA_ORG}"\' -e serial_number_file=${VIPTELA_SERIAL_FILE} -e viptela_cert_dir=${WORKSPACE}/myCA', tags: 'check_control', playbook: 'configure.yml'
                }
           steps {
                echo 'Configure Viptela Edge...'
                withCredentials([file(credentialsId: 'viptela-serial-file', variable: 'VIPTELA_SERIAL_FILE')]) {
                    ansiblePlaybook disableHostKeyChecking: true, extras: '-e virl_tag=jenkins -e \'organization_name="${VIPTELA_ORG}"\' -e serial_number_file=${VIPTELA_SERIAL_FILE} -e viptela_cert_dir=${WORKSPACE}/myCA', tags: 'edge', playbook: 'configure.yml'
                }
           steps {
                echo 'Check Viptela Edge...'
                withCredentials([file(credentialsId: 'viptela-serial-file', variable: 'VIPTELA_SERIAL_FILE')]) {
                    ansiblePlaybook disableHostKeyChecking: true, extras: '-e virl_tag=jenkins -e \'organization_name="${VIPTELA_ORG}"\' -e serial_number_file=${VIPTELA_SERIAL_FILE} -e viptela_cert_dir=${WORKSPACE}/myCA', tags: 'check_edge', playbook: 'configure.yml'
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


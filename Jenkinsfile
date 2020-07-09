buildVersion = new Date().format("yyyyMMddHHmmss")

pipeline {
    agent { node { label 'docker_image' } }

    options {
        disableConcurrentBuilds()
    }

    stages {
        stage('Build Jupyter images') {
            steps {
                script {
                    sh "cd minimal && docker build -t saagie/jupyter-python-nbk:v2-minimal_$buildVersion ."
                    sh "cd base && docker build -t saagie/jupyter-python-nbk:v2-base_$buildVersion -t saagie/jupyter-python-nbk:v2_$buildVersion ."
                    sh "cd scipy && docker build -t saagie/jupyter-python-nbk:v2-scipy_$buildVersion ."
                }
            }
        }

        stage('Push techno images') {
            steps {
                script {
                    withCredentials(
        [usernamePassword(credentialsId: '8fc4964e-30c6-4bb9-8a19-69e37ea905b6',
                usernameVariable: 'USERNAME',
                passwordVariable: 'PASSWORD')]) {

                        sh "docker login -u $USERNAME -p $PASSWORD"
                        sh "docker push saagie/jupyter-python-nbk:v2-minimal_$buildVersion"
                        sh "docker push saagie/jupyter-python-nbk:v2-base_$buildVersion"
                        sh "docker push saagie/jupyter-python-nbk:v2-scipy_$buildVersion"
                        sh "docker push saagie/jupyter-python-nbk:v2_$buildVersion"
                    }
                }
            }
        }
    }
}

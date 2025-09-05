pipeline {
    agent any

    environment {
        IMAGE_TAG = "${BUILD_NUMBER}"
        DOCKER_IMAGE = "eligetipavankumar/affine:${IMAGE_TAG}"
        K8S_MANIFEST = "${WORKSPACE}/k8s/deployment.yaml"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'canary', url: 'https://github.com/eligetipavankumar/AFFiNE.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat "docker build -t ${DOCKER_IMAGE} ."
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([string(credentialsId: 'DOCKER_USER', variable: 'DOCKER_HUB_PASS')]) {
                    bat """
                        echo %DOCKER_HUB_PASS% | docker login -u eligetipavankumar --password-stdin
                        docker push ${DOCKER_IMAGE}
                    """
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                bat "kubectl apply -f ${K8S_MANIFEST}"
            }
        }
    }
}


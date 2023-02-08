pipeline {
    agent none
    stages {
        stage('Update KVM Debian') {
            agent {
                label "KVMDEBTEST01"
            }
            steps {
                sh"""
                sudo su cblock -c "source ~/.profile; rsync_git_prod; rsync_git_dev" || exit 0
                sudo su cblock -c "source ~/.profile; apt_setup" || exit 0
                """
            }
        }
        stage('Update Dev') {
            agent {
                label "HQDEBDEV01"
            }
            steps {
                sh"""
                sudo su cblock -c "source ~/.profile; rsync_git_prod; rsync_git_dev" || exit 0
                sudo su cblock -c "source ~/.profile; apt_setup" || exit 0
                """
            }
        }
        stage('Update DELL') {
            agent {
                label "HQDEBDELL01"
            }
            steps {
                sh"""
                sudo su cblock -c "source ~/.profile; rsync_git_prod; rsync_git_dev" || exit 0
                sudo su cblock -c "source ~/.profile; apt_setup" || exit 0
                """
            }
        }
        stage('Update Lenovo') {
            agent {
                label "HQDEBLENOVO01"
            }
            steps {
                sh"""
                sudo su cblock -c "source ~/.profile; rsync_git_prod; rsync_git_dev" || exit 0
                sudo su cblock -c "source ~/.profile; apt_setup" || exit 0
                """
            }
        }
        stage('Update Prod') {
            agent {
                label "HQDEBPROD01"
            }
            steps {
                sh"""
                sudo su cblock -c "source ~/.profile; apt_setup" || exit 0
                """
            }
        }
    }
}

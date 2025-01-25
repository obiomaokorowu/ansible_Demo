pipeline{
  agent any  
  stages{  
     
      stage('Git checkout') {
            steps {
                git branch: 'main', credentialsId: '', url: 'https://github.com/obiomaokorowu/ansible_Demo.git'
            }
        }
      stage("Run an ansible playbook"){
        steps{
          ansiblePlaybook credentialsId: 'SSH_KEY', disableHostKeyChecking: true, inventory: 'hosts', playbook: 'ansible_playbook.yaml', vaultTmpPath: ''
        }
      }
      stage("Print Installation Is Complete"){
        steps{
           sh"echo Your Installation Was Successful  On All Servers"
        }
      }
  }
}

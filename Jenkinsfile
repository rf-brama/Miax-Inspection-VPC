pipeline {
    agent any
    parameters { 
      choice(name: 'Environment', choices: ['dev', 'qa', 'prod'], description: 'Select the environment to use')
      choice(name: 'Action', choices: ['', 'plan-apply', 'destroy'], description: 'Select the action to use')
    }
    stages{
        
        // stage('clean workspaces -----------') { 
        //     steps {
        //       cleanWs()
        //       sh 'env'
        //     } //steps
        // }  //stage

        //${params.Action}
        // stage("git clone code terraform"){
        //     steps {
        //         git credentialsId: '10879bde-beaa-4f61-8430-aec2791975ca', url: 'https://github.com/PegaChucho/Terraform-jenkins-test.git'
        //         sh 'pwd' 
        //         sh 'ls -l'
        //     } //steps
        // }  //stage
    
        stage('Terraform init----') {
         steps {
            // sh '/usr/local/bin/terraform --version'
            sh '/usr/local/bin/terraform init -input=false'
            //sh '/usr/local/bin/terraform init -reconfigure -input=false'//This command is for reconfiguring state
            } //steps
        }  //stage

        stage('Terraform plan----') {
            steps {
               sh '/usr/local/bin/terraform plan -refresh=true'
            } //steps
        }  //stage
        
        stage('Action confirmation') {
            steps {
                script {
                    def userInput = input(id: 'confirm', message: params.ACCION + '?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
                }
            }
        }
        
        stage('Terraform apply or destroy ----------------') {
            steps {
               sh 'echo "Start"'
            script{  
                if (params.Action == "destroy"){
                         sh 'echo "Started" + params.Action'   
                         sh '/usr/local/bin/terraform destroy -auto-approve'
                } else {
                         sh ' echo  "Started" + params.Action'                 
                         sh '/usr/local/bin/terraform apply -refresh=true -auto-approve'  
                }  // if

            }
            } //steps
        }  //stage

   }  // stages
} //pipeline
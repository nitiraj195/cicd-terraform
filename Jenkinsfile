pipeline {
    agent any
    tools {
        "org.jenkinsci.plugins.terraform.TerraformInstallation" "terraform-0.15.4"
    }
    parameters {
        string(name: 'environment', defaultValue: 'default', description: 'Workspace/environment file to use for deployment')
        choice(choices:['plan','apply','destroy'], name: 'action', description: 'Select the action')
    }

    environment {
        TF_HOME = tool('terraform-0.15.4')
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        PATH = "$TF_HOME:$PATH"
        TF_IN_AUTOMATION      = '1'
        ACTION = "${params.action}"
    }

    stages {
        stage('Envs Prep') {
        steps {
                sh "terraform init -force-copy"
                sh 'terraform workspace select ${environment}'
            }
        }
        stage('Plan') {
            when { anyOf
                          {
                            environment name: 'ACTION', value: 'plan';
                            environment name: 'ACTION', value: 'apply'
					                }

            }
            steps {
                sh "terraform plan -input=false -out tfplan --var-file=env/${params.environment}.tfvars"
                sh 'terraform show -no-color tfplan > tfplan.txt'
            }
        }

        stage('Approval') {
          steps {
            script {
              def userInput = input(id: 'confirm', message: 'Apply Terraform?', parameters: [ [$class: 'BooleanParameterDefinition', defaultValue: false, description: 'Apply terraform', name: 'confirm'] ])
              }
            }
        }

        stage('Apply') {
          when { anyOf
                        {
                          environment name: 'ACTION', value: 'apply'
                        }
          }
          steps {
                sh "terraform apply -input=false tfplan"
            }
        }

        stage('Destroy') {    
    			when { anyOf
    					{
    						environment name: 'ACTION', value: 'destroy';
    					}
    				}
    			steps {
    				script {
    					def IS_APPROVED = input(
    						message: "Destroy ${ENV_NAME} !?!",
    						ok: "Yes",
    						parameters: [
    							string(name: 'IS_APPROVED', defaultValue: 'No', description: 'Think again!!!')
    						]
    					)
    					if (IS_APPROVED != 'Yes') {
    						currentBuild.result = "ABORTED"
    						error "User cancelled"
    					} else {
    						sh "terraform destroy -input=false --var-file=env/${params.environment}.tfvars -auto-approve"
    				}
    			}
        }
    }
}
}

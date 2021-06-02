pipeline {
    agent any
    tools {
        "org.jenkinsci.plugins.terraform.TerraformInstallation" "terraform-0.15.4"
    }
    parameters {
        string(name: 'environment', defaultValue: 'default', description: 'Workspace/environment file to use for deployment')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        choice(choices:['apply','destroy'], name: 'action', description: 'Select the action')
    }

    environment {
        TF_HOME = tool('terraform-0.15.4')
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        PATH = "$TF_HOME:$PATH"
        TF_IN_AUTOMATION      = '1'
    }

    stages {
        stage('Plan') {
            steps {
                script {
                    currentBuild.displayName = params.version
                }
                sh "terraform init -force-copy"
                sh 'terraform workspace select ${environment}'
                sh "terraform plan -input=false -out tfplan --var-file=env/${params.environment}.tfvars"
                sh 'terraform show -no-color tfplan > tfplan.txt'
            }
        }

        stage('Approval') {
            when {
                not {
                    equals expected: true, actual: params.autoApprove
                }
            }

            steps {
                script {
                    def plan = readFile 'tfplan.txt'
                    input message: "Do you want to apply the plan?",
                        parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                }
            }
        }

        stage('Apply') {
          when {
              expression {params.action == 'apply'}
          }
          steps {
                sh "terraform apply -input=false tfplan"
            }
        }

        stage('Destroy') {
          when {
              expression {params.action == 'destroy'}
          }
          steps {
                sh "terraform destroy -input=false --var-file=env/${params.environment}.tfvars -auto-approve"
            }
        }
    }
}

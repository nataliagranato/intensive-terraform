# Pipelines CI/CD para Terraform: Guia Multiplataforma

![CI/CD Pipelines](https://via.placeholder.com/800x200/2E86AB/FFFFFF?text=CI%2FCD+Pipelines+for+Terraform)

Este guia abrange a implementação de pipelines CI/CD para Terraform em diferentes plataformas, fornecendo exemplos práticos, melhores práticas e comparações entre as principais soluções do mercado.

## Panorama geral das plataformas CI/CD

### Comparação entre plataformas

| Plataforma | Pontos Fortes | Casos de Uso | Integração Terraform |
|------------|---------------|--------------|---------------------|
| **GitHub Actions** | Integração nativa GitHub, marketplace rico, gratuito para repos públicos | Projetos open source, equipes pequenas a médias | Excelente (action oficial HashiCorp) |
| **GitLab CI/CD** | Integração completa DevOps, runners flexíveis, registry próprio | Empresas que preferem solução completa | Muito boa (componente oficial) |
| **Azure DevOps** | Integração Azure nativa, enterprise features, hybrid cloud | Organizações Microsoft/Azure | Excelente (extensões oficiais) |
| **Jenkins** | Flexibilidade máxima, plugins abundantes, self-hosted | Ambientes complexos, necessidades customizadas | Boa (plugins da comunidade) |
| **CircleCI** | Performance, orbs reutilizáveis, containers nativos | Equipes focadas em performance e simplicity | Boa (orb oficial) |
| **AWS CodePipeline** | Integração AWS nativa, serverless, pay-per-use | Workloads AWS-first | Boa (integração com CodeBuild) |

## GitHub Actions para Terraform

### Características principais

- **Integração nativa** com repositórios GitHub
- **Action oficial** da HashiCorp
- **Secrets management** integrado
- **Matrix builds** para múltiplos ambientes
- **Marketplace** rico em extensões

### Exemplo completo

```yaml
# .github/workflows/terraform.yml
name: 'Terraform CI/CD'

on:
  push:
    branches: [ "main", "develop" ]
  pull_request:
    branches: [ "main" ]

env:
  TF_VERSION: '1.5.0'
  AWS_DEFAULT_REGION: 'us-east-1'

jobs:
  validate:
    name: 'Validate'
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}

    - name: Terraform Format
      run: terraform fmt -check -recursive

    - name: Terraform Init
      run: terraform init -backend=false

    - name: Terraform Validate
      run: terraform validate

    - name: Run TFLint
      uses: terraform-linters/setup-tflint@v4
      with:
        tflint_version: latest

    - name: Init TFLint
      run: tflint --init

    - name: Run TFLint
      run: tflint -f compact

  plan:
    name: 'Plan'
    runs-on: ubuntu-latest
    needs: validate
    if: github.event_name == 'pull_request'
    environment: development
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}
        cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

    - name: Terraform Init
      run: terraform init

    - name: Terraform Plan
      id: plan
      run: terraform plan -no-color -out=tfplan
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

    - name: Upload Plan
      uses: actions/upload-artifact@v4
      with:
        name: terraform-plan
        path: tfplan

  deploy:
    name: 'Deploy'
    runs-on: ubuntu-latest
    needs: validate
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    environment: production
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ env.TF_VERSION }}

    - name: Terraform Init
      run: terraform init

    - name: Terraform Apply
      run: terraform apply -auto-approve
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

### Recursos avançados

```yaml
  security-scan:
    name: 'Security Scan'
    runs-on: ubuntu-latest
    needs: validate
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Run Checkov
      uses: bridgecrewio/checkov-action@master
      with:
        directory: .
        framework: terraform
        output_format: sarif
        output_file_path: reports/results.sarif

    - name: Upload SARIF file
      uses: github/codeql-action/upload-sarif@v3
      with:
        sarif_file: reports/results.sarif

    - name: Run tfsec
      uses: aquasecurity/tfsec-action@v1.0.3
      with:
        soft_fail: true
```

## GitLab CI/CD para Terraform

### Características principais

- **Integração completa** com GitLab
- **Componente oficial** para OpenTofu/Terraform
- **Merge Request integration** nativa
- **GitLab-managed state** disponível
- **Container registry** integrado

### Configuração básica com componente oficial

```yaml
# .gitlab-ci.yml
include:
  - component: gitlab.com/components/opentofu/validate-plan-apply@1.0.0
    inputs:
      version: 1.5.0
      opentofu_version: 1.6.0
      root_dir: terraform/
      state_name: production

stages: [validate, build, deploy]

variables:
  TF_ROOT: ${CI_PROJECT_DIR}/terraform
  TF_ADDRESS: ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/default

before_script:
  - cd $TF_ROOT
```

### Pipeline customizado avançado

```yaml
# .gitlab-ci.yml
stages:
  - validate
  - plan  
  - deploy
  - cleanup

variables:
  TF_ROOT: ${CI_PROJECT_DIR}
  TF_ADDRESS: ${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/terraform/state/production
  TF_USERNAME: gitlab-ci-token
  TF_PASSWORD: ${CI_JOB_TOKEN}
  TF_HTTP_LOCK_ADDRESS: ${TF_ADDRESS}/lock
  TF_HTTP_LOCK_METHOD: POST
  TF_HTTP_UNLOCK_ADDRESS: ${TF_ADDRESS}/lock
  TF_HTTP_UNLOCK_METHOD: DELETE
  TF_HTTP_RETRY_WAIT_MIN: 5

cache:
  key: terraform
  paths:
    - .terraform/

before_script:
  - cd $TF_ROOT
  - terraform --version
  - terraform init

validate:
  stage: validate
  script:
    - terraform fmt -check
    - terraform validate
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
    - if: '$CI_COMMIT_BRANCH == "main"'

plan:
  stage: plan
  script:
    - terraform plan -out="planfile"
  artifacts:
    name: plan
    paths:
      - planfile
    reports:
      terraform: planfile.json
  before_script:
    - cd $TF_ROOT
    - terraform init
    - terraform plan -out="planfile"
    - terraform show -json planfile > planfile.json
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'

apply:
  stage: deploy
  script:
    - terraform apply -input=false "planfile"
  dependencies:
    - plan
  environment:
    name: production
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'
      when: manual

security_scan:
  stage: validate
  image: 
    name: checkov/checkov:latest
    entrypoint: [""]
  script:
    - checkov -d . --framework terraform --output-format json --output-file checkov-report.json
  artifacts:
    reports:
      junit: checkov-report.json
    paths:
      - checkov-report.json
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
    - if: '$CI_COMMIT_BRANCH == "main"'
```

### Integração com Merge Requests

```yaml
# Template para reutilização
.terraform_template: &terraform_template
  image: 
    name: hashicorp/terraform:1.5.0
    entrypoint: [""]
  before_script:
    - cd $TF_ROOT
    - terraform init
  variables:
    TF_IN_AUTOMATION: "true"

plan_development:
  <<: *terraform_template
  stage: plan
  environment:
    name: development
  script:
    - terraform plan -var-file="environments/dev.tfvars" -out=plan-dev
    - terraform show -json plan-dev > plan-dev.json
  artifacts:
    reports:
      terraform: plan-dev.json
  rules:
    - if: '$CI_MERGE_REQUEST_TARGET_BRANCH_NAME == "develop"'

plan_production:
  <<: *terraform_template
  stage: plan
  environment:
    name: production
  script:
    - terraform plan -var-file="environments/prod.tfvars" -out=plan-prod
    - terraform show -json plan-prod > plan-prod.json
  artifacts:
    reports:
      terraform: plan-prod.json
  rules:
    - if: '$CI_MERGE_REQUEST_TARGET_BRANCH_NAME == "main"'
```

## Azure DevOps para Terraform

### Características principais

- **Integração nativa** com Azure
- **Extensões oficiais** da Microsoft
- **Variable groups** para secrets
- **Environments** com approvals
- **Service connections** para autenticação

### Pipeline YAML

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main
      - develop

pr:
  branches:
    include:
      - main

variables:
  - group: terraform-variables
  - name: terraformVersion
    value: '1.5.0'
  - name: serviceConnection
    value: 'azure-terraform-spn'

stages:
- stage: Validate
  displayName: 'Validate and Plan'
  jobs:
  - job: TerraformValidate
    displayName: 'Terraform Validate'
    pool:
      vmImage: 'ubuntu-latest'
    
    steps:
    - task: TerraformInstaller@0
      displayName: 'Install Terraform'
      inputs:
        terraformVersion: $(terraformVersion)

    - task: TerraformTaskV4@0
      displayName: 'Terraform Init'
      inputs:
        provider: 'azurerm'
        command: 'init'
        backendServiceArm: $(serviceConnection)
        backendAzureRmResourceGroupName: 'terraform-state-rg'
        backendAzureRmStorageAccountName: 'terraformstatestorage'
        backendAzureRmContainerName: 'tfstate'
        backendAzureRmKey: 'terraform.tfstate'

    - task: TerraformTaskV4@0
      displayName: 'Terraform Format Check'
      inputs:
        provider: 'azurerm'
        command: 'custom'
        customCommand: 'fmt'
        customOptions: '-check -diff'

    - task: TerraformTaskV4@0
      displayName: 'Terraform Validate'
      inputs:
        provider: 'azurerm'
        command: 'validate'

  - job: TerraformPlan
    displayName: 'Terraform Plan'
    dependsOn: TerraformValidate
    condition: succeeded()
    
    steps:
    - task: TerraformInstaller@0
      displayName: 'Install Terraform'
      inputs:
        terraformVersion: $(terraformVersion)

    - task: TerraformTaskV4@0
      displayName: 'Terraform Init'
      inputs:
        provider: 'azurerm'
        command: 'init'
        backendServiceArm: $(serviceConnection)
        backendAzureRmResourceGroupName: 'terraform-state-rg'
        backendAzureRmStorageAccountName: 'terraformstatestorage'
        backendAzureRmContainerName: 'tfstate'
        backendAzureRmKey: 'terraform.tfstate'

    - task: TerraformTaskV4@0
      displayName: 'Terraform Plan'
      inputs:
        provider: 'azurerm'
        command: 'plan'
        environmentServiceNameAzureRM: $(serviceConnection)
        publishPlanResults: 'Terraform Plan'

    - task: PublishTestResults@2
      displayName: 'Publish Terraform Plan'
      inputs:
        testResultsFormat: 'VSTest'
        testResultsFiles: '**/*planResults.xml'
      condition: succeededOrFailed()

- stage: DeployDev
  displayName: 'Deploy to Development'
  dependsOn: Validate
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/develop'))
  
  jobs:
  - deployment: DeployTerraform
    displayName: 'Deploy Terraform'
    environment: 'Development'
    pool:
      vmImage: 'ubuntu-latest'
    
    strategy:
      runOnce:
        deploy:
          steps:
          - task: TerraformInstaller@0
            displayName: 'Install Terraform'
            inputs:
              terraformVersion: $(terraformVersion)

          - task: TerraformTaskV4@0
            displayName: 'Terraform Init'
            inputs:
              provider: 'azurerm'
              command: 'init'
              backendServiceArm: $(serviceConnection)
              backendAzureRmResourceGroupName: 'terraform-state-rg'
              backendAzureRmStorageAccountName: 'terraformstatestorage'
              backendAzureRmContainerName: 'tfstate'
              backendAzureRmKey: 'dev-terraform.tfstate'

          - task: TerraformTaskV4@0
            displayName: 'Terraform Apply'
            inputs:
              provider: 'azurerm'
              command: 'apply'
              environmentServiceNameAzureRM: $(serviceConnection)
              commandOptions: '-var-file="environments/dev.tfvars"'

- stage: DeployProd
  displayName: 'Deploy to Production'
  dependsOn: Validate
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  
  jobs:
  - deployment: DeployTerraform
    displayName: 'Deploy Terraform'
    environment: 'Production'
    pool:
      vmImage: 'ubuntu-latest'
    
    strategy:
      runOnce:
        deploy:
          steps:
          - task: TerraformInstaller@0
            displayName: 'Install Terraform'
            inputs:
              terraformVersion: $(terraformVersion)

          - task: TerraformTaskV4@0
            displayName: 'Terraform Init'
            inputs:
              provider: 'azurerm'
              command: 'init'
              backendServiceArm: $(serviceConnection)
              backendAzureRmResourceGroupName: 'terraform-state-rg'
              backendAzureRmStorageAccountName: 'terraformstatestorage'
              backendAzureRmContainerName: 'tfstate'
              backendAzureRmKey: 'prod-terraform.tfstate'

          - task: TerraformTaskV4@0
            displayName: 'Terraform Apply'
            inputs:
              provider: 'azurerm'
              command: 'apply'
              environmentServiceNameAzureRM: $(serviceConnection)
              commandOptions: '-var-file="environments/prod.tfvars"'
```

### Pipeline clássico (Release)

```yaml
# Template de release pipeline
variables:
  - name: terraformVersion
    value: '1.5.0'
  - group: terraform-secrets

stages:
- stage: Plan
  jobs:
  - job: TerraformPlan
    steps:
    - task: AzureCLI@2
      displayName: 'Setup Backend'
      inputs:
        azureSubscription: 'terraform-service-connection'
        scriptType: 'bash'
        scriptLocation: 'inlineScript'
        inlineScript: |
          az storage account create \
            --name terraformstatestorage \
            --resource-group terraform-state-rg \
            --location eastus \
            --sku Standard_LRS

    - task: ms-devlabs.custom-terraform-tasks.custom-terraform-installer-task.TerraformInstaller@0
      displayName: 'Install Terraform'
      inputs:
        terraformVersion: $(terraformVersion)

    - task: ms-devlabs.custom-terraform-tasks.custom-terraform-release-task.TerraformTaskV4@0
      displayName: 'Terraform: init'
      inputs:
        provider: 'azurerm'
        command: 'init'
        backendServiceArm: 'terraform-service-connection'
        backendAzureRmResourceGroupName: 'terraform-state-rg'
        backendAzureRmStorageAccountName: 'terraformstatestorage'
        backendAzureRmContainerName: 'tfstate'
        backendAzureRmKey: '$(System.TeamProject)-$(Build.Repository.Name).tfstate'

    - task: ms-devlabs.custom-terraform-tasks.custom-terraform-release-task.TerraformTaskV4@0
      displayName: 'Terraform: plan'
      inputs:
        provider: 'azurerm'
        command: 'plan'
        environmentServiceNameAzureRM: 'terraform-service-connection'
        runAzLogin: true
        publishPlanResults: 'terraform-plan'
```

## Jenkins para Terraform

### Características principais

- **Flexibilidade máxima** de configuração
- **Plugins abundantes** para integração
- **Pipeline as Code** com Jenkinsfile
- **Distributed builds** com agents
- **Self-hosted** ou cloud

### Jenkinsfile declarativo

```groovy
// Jenkinsfile
pipeline {
    agent any
    
    parameters {
        choice(
            choices: ['plan', 'apply', 'destroy'],
            description: 'Terraform action to perform',
            name: 'TERRAFORM_ACTION'
        )
        choice(
            choices: ['dev', 'staging', 'prod'],
            description: 'Environment to deploy',
            name: 'ENVIRONMENT'
        )
    }
    
    environment {
        TF_VERSION = '1.5.0'
        AWS_DEFAULT_REGION = 'us-east-1'
        TF_IN_AUTOMATION = 'true'
        TF_INPUT = 'false'
        TF_PLUGIN_CACHE_DIR = "${WORKSPACE}/.terraform.d/plugin-cache"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup') {
            steps {
                script {
                    // Install Terraform
                    sh '''
                        if [ ! -f /usr/local/bin/terraform ]; then
                            wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
                            unzip terraform_${TF_VERSION}_linux_amd64.zip
                            sudo mv terraform /usr/local/bin/
                            rm terraform_${TF_VERSION}_linux_amd64.zip
                        fi
                        terraform version
                    '''
                    
                    // Create plugin cache directory
                    sh 'mkdir -p ${TF_PLUGIN_CACHE_DIR}'
                }
            }
        }
        
        stage('Validate') {
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    sh 'terraform fmt -check'
                    sh 'terraform init -backend=false'
                    sh 'terraform validate'
                }
            }
        }
        
        stage('Security Scan') {
            parallel {
                stage('TFSec') {
                    steps {
                        script {
                            sh '''
                                curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
                                tfsec . --format json --out tfsec-results.json
                            '''
                            
                            publishHTML([
                                allowMissing: false,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: '.',
                                reportFiles: 'tfsec-results.json',
                                reportName: 'TFSec Security Report'
                            ])
                        }
                    }
                }
                
                stage('Checkov') {
                    steps {
                        sh '''
                            pip3 install checkov
                            checkov -d . --framework terraform --output json --output-file checkov-results.json
                        '''
                        
                        publishHTML([
                            allowMissing: false,
                            alwaysLinkToLastBuild: true,
                            keepAll: true,
                            reportDir: '.',
                            reportFiles: 'checkov-results.json',
                            reportName: 'Checkov Security Report'
                        ])
                    }
                }
            }
        }
        
        stage('Plan') {
            when {
                anyOf {
                    equals expected: 'plan', actual: params.TERRAFORM_ACTION
                    equals expected: 'apply', actual: params.TERRAFORM_ACTION
                }
            }
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    withCredentials([
                        string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        sh 'terraform init'
                        script {
                            def planResult = sh(
                                script: 'terraform plan -detailed-exitcode -out=tfplan',
                                returnStatus: true
                            )
                            
                            if (planResult == 0) {
                                echo "No changes detected"
                                env.PLAN_RESULT = "no-changes"
                            } else if (planResult == 1) {
                                error "Terraform plan failed"
                            } else if (planResult == 2) {
                                echo "Changes detected"
                                env.PLAN_RESULT = "changes"
                                
                                // Generate human-readable plan
                                sh 'terraform show -no-color tfplan > plan-output.txt'
                                
                                // Archive plan files
                                archiveArtifacts artifacts: 'tfplan,plan-output.txt', fingerprint: true
                            }
                        }
                    }
                }
            }
        }
        
        stage('Approve') {
            when {
                allOf {
                    equals expected: 'apply', actual: params.TERRAFORM_ACTION
                    environment name: 'PLAN_RESULT', value: 'changes'
                    anyOf {
                        branch 'main'
                        branch 'master'
                    }
                }
            }
            steps {
                script {
                    def plan = readFile('environments/' + params.ENVIRONMENT + '/plan-output.txt')
                    
                    def approval = input(
                        message: 'Review the Terraform plan and approve deployment',
                        parameters: [
                            text(name: 'PLAN_REVIEW', defaultValue: plan, description: 'Terraform Plan')
                        ],
                        submitterParameter: 'APPROVER'
                    )
                    
                    echo "Deployment approved by: ${approval.APPROVER}"
                }
            }
        }
        
        stage('Apply') {
            when {
                allOf {
                    equals expected: 'apply', actual: params.TERRAFORM_ACTION
                    environment name: 'PLAN_RESULT', value: 'changes'
                }
            }
            steps {
                dir("environments/${params.ENVIRONMENT}") {
                    withCredentials([
                        string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                        string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                    ]) {
                        sh 'terraform apply -auto-approve tfplan'
                        
                        // Generate outputs
                        sh 'terraform output -json > terraform-outputs.json'
                        archiveArtifacts artifacts: 'terraform-outputs.json', fingerprint: true
                    }
                }
            }
        }
        
        stage('Destroy') {
            when {
                equals expected: 'destroy', actual: params.TERRAFORM_ACTION
            }
            steps {
                script {
                    def confirmation = input(
                        message: 'Are you sure you want to destroy the infrastructure?',
                        parameters: [
                            booleanParam(name: 'CONFIRM_DESTROY', defaultValue: false, description: 'Check to confirm destruction')
                        ]
                    )
                    
                    if (confirmation) {
                        dir("environments/${params.ENVIRONMENT}") {
                            withCredentials([
                                string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                                string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                            ]) {
                                sh 'terraform init'
                                sh 'terraform destroy -auto-approve'
                            }
                        }
                    } else {
                        error "Destruction cancelled by user"
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Clean up terraform files
            sh 'find . -name ".terraform" -type d -exec rm -rf {} + || true'
            sh 'find . -name "*.tfplan" -delete || true'
            
            // Publish test results if available
            publishTestResults testResultsPattern: '**/test-results.xml', allowEmptyResults: true
        }
        
        success {
            echo 'Pipeline completed successfully!'
            
            // Send notification to Slack
            slackSend(
                channel: '#infrastructure',
                color: 'good',
                message: "✅ Terraform ${params.TERRAFORM_ACTION} completed successfully for ${params.ENVIRONMENT} environment\nJob: ${env.JOB_NAME} - Build: ${env.BUILD_NUMBER}"
            )
        }
        
        failure {
            echo 'Pipeline failed!'
            
            // Send notification to Slack
            slackSend(
                channel: '#infrastructure',
                color: 'danger',
                message: "❌ Terraform ${params.TERRAFORM_ACTION} failed for ${params.ENVIRONMENT} environment\nJob: ${env.JOB_NAME} - Build: ${env.BUILD_NUMBER}\nCheck: ${env.BUILD_URL}"
            )
        }
    }
}
```

### Jenkins com Pipeline Library

```groovy
// vars/terraformPipeline.groovy (shared library)
def call(Map config) {
    pipeline {
        agent any
        
        environment {
            TF_VERSION = config.terraformVersion ?: '1.5.0'
            TF_ENVIRONMENT = config.environment
            TF_WORKING_DIR = config.workingDir ?: '.'
        }
        
        stages {
            stage('Prepare') {
                steps {
                    terraformSetup()
                }
            }
            
            stage('Validate') {
                steps {
                    terraformValidate(env.TF_WORKING_DIR)
                }
            }
            
            stage('Plan') {
                steps {
                    terraformPlan(env.TF_WORKING_DIR, env.TF_ENVIRONMENT)
                }
            }
            
            stage('Apply') {
                when {
                    branch 'main'
                }
                steps {
                    terraformApply(env.TF_WORKING_DIR)
                }
            }
        }
    }
}

// Jenkinsfile usando a library
@Library('terraform-shared-library') _

terraformPipeline {
    terraformVersion = '1.5.0'
    environment = 'production'
    workingDir = './terraform'
}
```

## CircleCI para Terraform

### Características principais

- **Performance otimizada** com containers
- **Orbs reutilizáveis** para Terraform
- **Workflows paralelos** eficientes
- **Docker layer caching** disponível
- **SSH debugging** integrado

### Configuração com Orb oficial

```yaml
# .circleci/config.yml
version: 2.1

orbs:
  terraform: circleci/terraform@3.2.1
  aws-cli: circleci/aws-cli@3.1.1

workflows:
  terraform-workflow:
    jobs:
      - terraform/fmt:
          checkout: true
          context: terraform
      
      - terraform/validate:
          checkout: true
          context: terraform
          requires:
            - terraform/fmt
            
      - terraform/plan:
          checkout: true
          context: terraform
          persist-workspace: true
          requires:
            - terraform/validate
          filters:
            branches:
              ignore: main
              
      - terraform/plan-and-apply:
          checkout: true
          context: terraform
          attach-workspace: true
          requires:
            - terraform/validate
          filters:
            branches:
              only: main

jobs:
  security-scan:
    docker:
      - image: cimg/python:3.9
    steps:
      - checkout
      - run:
          name: Install security tools
          command: |
            pip install checkov
            curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
      
      - run:
          name: Run Checkov
          command: |
            checkov -d . --framework terraform --output json --output-file checkov-results.json
      
      - run:
          name: Run tfsec
          command: |
            tfsec . --format json --out tfsec-results.json
      
      - store_artifacts:
          path: checkov-results.json
          destination: security-reports/checkov
      
      - store_artifacts:
          path: tfsec-results.json
          destination: security-reports/tfsec

  deploy-staging:
    docker:
      - image: cimg/base:stable
    steps:
      - checkout
      - terraform/install:
          terraform_version: "1.5.0"
      - run:
          name: Terraform Init
          command: |
            cd environments/staging
            terraform init
      - run:
          name: Terraform Plan
          command: |
            cd environments/staging
            terraform plan -out=tfplan
      - run:
          name: Terraform Apply
          command: |
            cd environments/staging
            terraform apply -auto-approve tfplan

  deploy-production:
    docker:
      - image: cimg/base:stable
    steps:
      - checkout
      - terraform/install:
          terraform_version: "1.5.0"
      - run:
          name: Terraform Init
          command: |
            cd environments/production
            terraform init
      - run:
          name: Terraform Plan
          command: |
            cd environments/production
            terraform plan -out=tfplan
      - run:
          name: Manual Approval Required
          command: |
            echo "Manual approval required for production deployment"
            echo "Plan file generated: tfplan"
      - run:
          name: Terraform Apply
          command: |
            cd environments/production
            terraform apply -auto-approve tfplan
```

### Configuração customizada avançada

```yaml
version: 2.1

executors:
  terraform-executor:
    docker:
      - image: hashicorp/terraform:1.5.0
    working_directory: ~/project

commands:
  setup-aws:
    steps:
      - run:
          name: Setup AWS CLI
          command: |
            apk add --no-cache aws-cli
            aws configure set region $AWS_DEFAULT_REGION

  terraform-init:
    parameters:
      working_directory:
        type: string
        default: "."
    steps:
      - run:
          name: Terraform Init
          command: |
            cd << parameters.working_directory >>
            terraform init \
              -backend-config="bucket=$TF_STATE_BUCKET" \
              -backend-config="key=$TF_STATE_KEY" \
              -backend-config="region=$AWS_DEFAULT_REGION"

jobs:
  validate:
    executor: terraform-executor
    steps:
      - checkout
      - run:
          name: Format Check
          command: terraform fmt -check -recursive
      - terraform-init
      - run:
          name: Validate
          command: terraform validate

  plan:
    executor: terraform-executor
    parameters:
      environment:
        type: string
    steps:
      - checkout
      - setup-aws
      - terraform-init:
          working_directory: "environments/<< parameters.environment >>"
      - run:
          name: Terraform Plan
          command: |
            cd environments/<< parameters.environment >>
            terraform plan -detailed-exitcode -out=tfplan
      - persist_to_workspace:
          root: .
          paths:
            - environments/<< parameters.environment >>/tfplan
      - store_artifacts:
          path: environments/<< parameters.environment >>/tfplan
          destination: plans/

  apply:
    executor: terraform-executor
    parameters:
      environment:
        type: string
    steps:
      - checkout
      - setup-aws
      - attach_workspace:
          at: .
      - terraform-init:
          working_directory: "environments/<< parameters.environment >>"
      - run:
          name: Terraform Apply
          command: |
            cd environments/<< parameters.environment >>
            terraform apply -auto-approve tfplan

workflows:
  terraform-pipeline:
    jobs:
      - validate

      - plan:
          name: plan-dev
          environment: development
          requires:
            - validate
          filters:
            branches:
              ignore: main

      - plan:
          name: plan-prod
          environment: production
          requires:
            - validate
          filters:
            branches:
              only: main

      - apply:
          name: apply-dev
          environment: development
          requires:
            - plan-dev
          filters:
            branches:
              ignore: main

      - hold-for-approval:
          type: approval
          requires:
            - plan-prod
          filters:
            branches:
              only: main

      - apply:
          name: apply-prod
          environment: production
          requires:
            - hold-for-approval
          filters:
            branches:
              only: main
```

## AWS CodePipeline para Terraform

### Características principais

- **Integração nativa** com serviços AWS
- **Serverless** e pay-per-use
- **CodeCommit/GitHub** como source
- **CodeBuild** para execução
- **Cross-account deployments** suportados

### CloudFormation para Pipeline

```yaml
# codepipeline-terraform.yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'Terraform CI/CD Pipeline with AWS CodePipeline'

Parameters:
  GitHubRepo:
    Type: String
    Description: GitHub repository name
  GitHubOwner:
    Type: String
    Description: GitHub repository owner
  GitHubToken:
    Type: String
    NoEcho: true
    Description: GitHub personal access token

Resources:
  # S3 Bucket for Pipeline Artifacts
  PipelineArtifactsBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${AWS::StackName}-pipeline-artifacts'
      VersioningConfiguration:
        Status: Enabled
      PublicAccessBlockConfiguration:
        BlockPublicAcls: true
        BlockPublicPolicy: true
        IgnorePublicAcls: true
        RestrictPublicBuckets: true

  # CodeBuild Service Role
  CodeBuildServiceRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: codebuild.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/PowerUserAccess
      Policies:
        - PolicyName: CodeBuildPolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - logs:CreateLogGroup
                  - logs:CreateLogStream
                  - logs:PutLogEvents
                Resource: !Sub 'arn:aws:logs:${AWS::Region}:${AWS::AccountId}:*'
              - Effect: Allow
                Action:
                  - s3:GetObject
                  - s3:PutObject
                Resource: !Sub '${PipelineArtifactsBucket}/*'

  # CodeBuild Project for Terraform
  TerraformBuildProject:
    Type: AWS::CodeBuild::Project
    Properties:
      Name: !Sub '${AWS::StackName}-terraform-build'
      ServiceRole: !GetAtt CodeBuildServiceRole.Arn
      Artifacts:
        Type: CODEPIPELINE
      Environment:
        Type: LINUX_CONTAINER
        ComputeType: BUILD_GENERAL1_MEDIUM
        Image: aws/codebuild/standard:5.0
        EnvironmentVariables:
          - Name: TF_VERSION
            Value: '1.5.0'
          - Name: AWS_DEFAULT_REGION
            Value: !Ref AWS::Region
      Source:
        Type: CODEPIPELINE
        BuildSpec: |
          version: 0.2
          phases:
            install:
              runtime-versions:
                python: 3.9
              commands:
                - echo "Installing Terraform"
                - wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
                - unzip terraform_${TF_VERSION}_linux_amd64.zip
                - mv terraform /usr/local/bin/
                - terraform version
                
                - echo "Installing security tools"
                - pip install checkov
                - curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
            
            pre_build:
              commands:
                - echo "Validating Terraform configuration"
                - terraform fmt -check -recursive
                - terraform init -backend=false
                - terraform validate
                
                - echo "Running security scans"
                - checkov -d . --framework terraform --output json --output-file checkov-results.json || true
                - tfsec . --format json --out tfsec-results.json || true
            
            build:
              commands:
                - echo "Terraform Plan phase"
                - terraform init
                - terraform plan -detailed-exitcode -out=tfplan
                
                - echo "Generating plan summary"
                - terraform show -json tfplan > plan.json
                
            post_build:
              commands:
                - echo "Build completed"
          
          artifacts:
            files:
              - tfplan
              - plan.json
              - checkov-results.json
              - tfsec-results.json

  # CodePipeline Service Role
  CodePipelineServiceRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              Service: codepipeline.amazonaws.com
            Action: sts:AssumeRole
      Policies:
        - PolicyName: PipelinePolicy
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - s3:GetObject
                  - s3:PutObject
                  - s3:GetBucketLocation
                  - s3:ListBucket
                Resource:
                  - !Sub '${PipelineArtifactsBucket}/*'
                  - !GetAtt PipelineArtifactsBucket.Arn
              - Effect: Allow
                Action:
                  - codebuild:BatchGetBuilds
                  - codebuild:StartBuild
                Resource: !GetAtt TerraformBuildProject.Arn

  # CodePipeline
  TerraformPipeline:
    Type: AWS::CodePipeline::Pipeline
    Properties:
      Name: !Sub '${AWS::StackName}-terraform-pipeline'
      RoleArn: !GetAtt CodePipelineServiceRole.Arn
      ArtifactStore:
        Type: S3
        Location: !Ref PipelineArtifactsBucket
      Stages:
        - Name: Source
          Actions:
            - Name: SourceAction
              ActionTypeId:
                Category: Source
                Owner: ThirdParty
                Provider: GitHub
                Version: '1'
              Configuration:
                Owner: !Ref GitHubOwner
                Repo: !Ref GitHubRepo
                Branch: main
                OAuthToken: !Ref GitHubToken
              OutputArtifacts:
                - Name: SourceOutput

        - Name: Plan
          Actions:
            - Name: TerraformPlan
              ActionTypeId:
                Category: Build
                Owner: AWS
                Provider: CodeBuild
                Version: '1'
              Configuration:
                ProjectName: !Ref TerraformBuildProject
              InputArtifacts:
                - Name: SourceOutput
              OutputArtifacts:
                - Name: PlanOutput

        - Name: ApprovalGate
          Actions:
            - Name: ManualApproval
              ActionTypeId:
                Category: Approval
                Owner: AWS
                Provider: Manual
                Version: '1'
              Configuration:
                CustomData: 'Please review the Terraform plan and approve deployment'

        - Name: Deploy
          Actions:
            - Name: TerraformApply
              ActionTypeId:
                Category: Build
                Owner: AWS
                Provider: CodeBuild
                Version: '1'
              Configuration:
                ProjectName: !Ref TerraformApplyProject
              InputArtifacts:
                - Name: PlanOutput

  # CodeBuild Project for Apply
  TerraformApplyProject:
    Type: AWS::CodeBuild::Project
    Properties:
      Name: !Sub '${AWS::StackName}-terraform-apply'
      ServiceRole: !GetAtt CodeBuildServiceRole.Arn
      Artifacts:
        Type: CODEPIPELINE
      Environment:
        Type: LINUX_CONTAINER
        ComputeType: BUILD_GENERAL1_MEDIUM
        Image: aws/codebuild/standard:5.0
        EnvironmentVariables:
          - Name: TF_VERSION
            Value: '1.5.0'
      Source:
        Type: CODEPIPELINE
        BuildSpec: |
          version: 0.2
          phases:
            install:
              commands:
                - wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
                - unzip terraform_${TF_VERSION}_linux_amd64.zip
                - mv terraform /usr/local/bin/
            
            build:
              commands:
                - terraform init
                - terraform apply -auto-approve tfplan
                
            post_build:
              commands:
                - terraform output -json > terraform-outputs.json
          
          artifacts:
            files:
              - terraform-outputs.json

Outputs:
  PipelineName:
    Description: Name of the CodePipeline
    Value: !Ref TerraformPipeline
  
  PipelineUrl:
    Description: URL of the CodePipeline
    Value: !Sub 'https://console.aws.amazon.com/codesuite/codepipeline/pipelines/${TerraformPipeline}/view'
```

### buildspec.yml customizado

```yaml
# buildspec.yml
version: 0.2

env:
  variables:
    TF_VERSION: "1.5.0"
    TF_IN_AUTOMATION: "true"
  parameter-store:
    TERRAFORM_TOKEN: "/terraform/cloud/token"

phases:
  install:
    runtime-versions:
      python: 3.9
    commands:
      # Install Terraform
      - echo "Installing Terraform ${TF_VERSION}"
      - wget https://releases.hashicorp.com/terraform/${TF_VERSION}/terraform_${TF_VERSION}_linux_amd64.zip
      - unzip terraform_${TF_VERSION}_linux_amd64.zip
      - mv terraform /usr/local/bin/terraform
      - terraform version
      
      # Install additional tools
      - pip install checkov
      - curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash
      - curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

  pre_build:
    commands:
      # Terraform validation
      - echo "Validating Terraform configuration..."
      - terraform fmt -check -recursive
      - terraform init -backend=false
      - terraform validate
      
      # Security scanning
      - echo "Running security scans..."
      - tflint --init
      - tflint -f compact
      - checkov -d . --framework terraform --output json --output-file reports/checkov.json
      - tfsec . --format json --out reports/tfsec.json
      
      # Cost estimation (if using Infracost)
      - |
        if [ -n "$INFRACOST_API_KEY" ]; then
          curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh
          infracost breakdown --path . --format json --out-file reports/infracost.json
        fi

  build:
    commands:
      - echo "Planning Terraform changes..."
      - terraform init
      
      # Create plan with different strategies based on branch
      - |
        if [ "$CODEBUILD_WEBHOOK_HEAD_REF" = "refs/heads/main" ]; then
          echo "Production deployment - creating detailed plan"
          terraform plan -detailed-exitcode -out=tfplan -var-file="environments/production.tfvars"
        else
          echo "Development deployment - creating plan"
          terraform plan -detailed-exitcode -out=tfplan -var-file="environments/development.tfvars"
        fi
      
      # Generate human-readable plan
      - terraform show -no-color tfplan > plan-output.txt
      - terraform show -json tfplan > plan.json

  post_build:
    commands:
      - echo "Build phase completed"
      
      # Apply only if this is a push to main branch
      - |
        if [ "$CODEBUILD_WEBHOOK_HEAD_REF" = "refs/heads/main" ] && [ "$CODEBUILD_WEBHOOK_EVENT" = "PUSH" ]; then
          echo "Applying Terraform changes to production..."
          terraform apply -auto-approve tfplan
          terraform output -json > terraform-outputs.json
        fi

artifacts:
  files:
    - tfplan
    - plan.json
    - plan-output.txt
    - terraform-outputs.json
    - reports/**/*
  name: terraform-artifacts

reports:
  security-reports:
    files:
      - 'reports/checkov.json'
      - 'reports/tfsec.json'
    file-format: 'JSON'
  
  cost-reports:
    files:
      - 'reports/infracost.json'
    file-format: 'JSON'
```

## Comparação de funcionalidades por plataforma

### Recursos nativos

| Funcionalidade | GitHub Actions | GitLab CI/CD | Azure DevOps | Jenkins | CircleCI | AWS CodePipeline |
|----------------|----------------|--------------|--------------|---------|----------|------------------|
| **Terraform Integration** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **State Management** | External | Integrated | External | External | External | External |
| **Secrets Management** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Multi-environment** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Approval Gates** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Plan Visualization** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Cost Estimation** | External | External | External | External | External | External |
| **Security Scanning** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |

### Custos típicos

| Plataforma | Modelo de Preço | Custo Aproximado | Gratuito |
|------------|-----------------|------------------|----------|
| **GitHub Actions** | Por minuto | $0.008/minuto | ✅ 2000 min/mês (privado) |
| **GitLab CI/CD** | Por usuário | $19/usuário/mês | ✅ 400 min/mês |
| **Azure DevOps** | Por usuário | $6/usuário/mês | ✅ 5 usuários |
| **Jenkins** | Infraestrutura | Variável | ✅ Open source |
| **CircleCI** | Por crédito | $15/mês (starter) | ✅ 6000 créditos/mês |
| **AWS CodePipeline** | Por pipeline | $1/pipeline/mês | ✅ 1 pipeline gratuito |

## Melhores práticas universais

### ✅ **Implementar sempre**

1. **Validação multi-camada**
   - Format checking (`terraform fmt`)
   - Syntax validation (`terraform validate`)
   - Security scanning (Checkov, tfsec)
   - Linting (TFLint)

2. **Estratégia de branches**
   - Feature branches para desenvolvimento
   - Pull/Merge requests obrigatórios
   - Proteção de branches principais
   - Approval workflows para produção

3. **Gerenciamento de estado**
   - Remote state storage seguro
   - State locking habilitado
   - Backup automático do estado
   - Versionamento do estado

4. **Secrets e credenciais**
   - Nunca hardcode credentials
   - Use platform-native secret management
   - Rotate credentials regularmente
   - Principle of least privilege

5. **Monitoramento e observabilidade**
   - Logs estruturados
   - Drift detection automático
   - Cost monitoring integrado
   - Alertas para falhas

### ❌ **Evitar sempre**

1. **Práticas perigosas**
   - Auto-approve em produção sem revisão
   - Shared service accounts
   - State storage não criptografado
   - Credentials em código

2. **Anti-patterns de pipeline**
   - Pipelines muito complexos sem documentação
   - Falta de rollback strategy
   - Deploy simultâneo no mesmo ambiente
   - Skip de validações por velocidade

3. **Problemas de configuração**
   - Hardcoded values em templates
   - Falta de parametrização por ambiente
   - Dependency hell entre recursos
   - State drift ignorado

## Escolhendo a plataforma ideal

### **Para startups e projetos pequenos**
- **GitHub Actions**: Se já usa GitHub
- **GitLab CI/CD**: Para solução completa
- **CircleCI**: Para simplicidade e performance

### **Para empresas médias**
- **Azure DevOps**: Se ecosystem Microsoft
- **GitLab CI/CD**: Para DevOps completo
- **Jenkins**: Para máxima flexibilidade

### **Para enterprises**
- **Azure DevOps**: Integração enterprise Microsoft
- **Jenkins**: Ambientes híbridos complexos
- **AWS CodePipeline**: AWS-first organizations

### **Para casos específicos**
- **Multi-cloud**: Jenkins ou GitLab CI/CD
- **Compliance rigoroso**: Azure DevOps ou Jenkins
- **Cost-sensitive**: GitHub Actions ou GitLab CI/CD

## Templates de migração

### De Jenkins para GitHub Actions

```yaml
# Migração conceitual
# Jenkins (Groovy) → GitHub Actions (YAML)

# Jenkins:
# pipeline {
#   agent any
#   stages {
#     stage('Plan') {
#       steps {
#         sh 'terraform plan'
#       }
#     }
#   }
# }

# GitHub Actions equivalente:
jobs:
  plan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
      - name: Terraform Plan
        run: terraform plan
```

### De Azure DevOps para GitLab CI/CD

```yaml
# Azure DevOps → GitLab CI/CD

# Azure DevOps:
# - task: TerraformTaskV4@0
#   displayName: 'Terraform Plan'
#   inputs:
#     provider: 'azurerm'
#     command: 'plan'

# GitLab CI/CD equivalente:
terraform_plan:
  stage: plan
  image: hashicorp/terraform:1.5.0
  script:
    - terraform init
    - terraform plan
```

## Conclusão

A escolha da plataforma de CI/CD para Terraform deve considerar:

### **Fatores técnicos**
- Integração com ferramentas existentes
- Requisitos de segurança e compliance
- Complexidade dos workflows necessários
- Performance e escalabilidade

### **Fatores organizacionais**
- Tamanho e expertise da equipe
- Budget disponível
- Estratégia de cloud (single/multi/hybrid)
- Cultura DevOps da organização

### **Recomendações finais**

1. **Comece simples** e evolua gradualmente
2. **Padronize** workflows entre equipes
3. **Documente** processos e decisões
4. **Monitore** e otimize continuamente
5. **Treine** equipes nas ferramentas escolhidas

Todas as plataformas apresentadas são capazes de implementar pipelines robustos para Terraform. A diferença está nos detalhes de integração, facilidade de uso e custos específicos para seu contexto organizacional.

## Recursos adicionais

- [Terraform Cloud/Enterprise](https://www.terraform.io/cloud)
- [HashiCorp Learn - Terraform Automation](https://learn.hashicorp.com/collections/terraform/automation)
- [Platform-specific Terraform Guides](https://registry.terraform.io/browse/providers)
- [Security Best Practices for IaC](https://www.hashicorp.com/resources/terraform-security-best-practices)
- [Cost Optimization with Infracost](https://www.infracost.io/docs/)

---

*Este guia fornece uma base sólida para implementar CI/CD com Terraform em qualquer plataforma. Adapte os exemplos conforme suas necessidades específicas e sempre mantenha as melhores práticas de segurança.*

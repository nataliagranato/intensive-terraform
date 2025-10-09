# GitHub Actions para Terraform: Automação CI/CD Completa

![GitHub Actions](https://github.githubassets.com/images/modules/site/features/actions-icon-actions.svg)

O GitHub Actions é uma plataforma de CI/CD nativa do GitHub que permite automatizar workflows de desenvolvimento diretamente no repositório. Para projetos Terraform, oferece integração poderosa para validação, planejamento e deployment de infraestrutura como código.

## Por que usar GitHub Actions com Terraform?

### 1. **Integração nativa**

- Execução automática baseada em eventos do Git
- Acesso direto ao código e Pull Requests
- Interface integrada com o GitHub
- Sem necessidade de ferramentas externas

### 2. **Segurança e compliance**

- Secrets management seguro
- Controle de acesso baseado em branches
- Aprovações obrigatórias para ambientes sensíveis
- Logs de auditoria completos

### 3. **Economia e escalabilidade**

- Minutos gratuitos para repositórios públicos
- Runners hospedados com software pré-instalado
- Paralelização automática de jobs
- Self-hosted runners para necessidades específicas

### 4. **Ecossistema rich**

- Marketplace com milhares de actions prontas
- Integração com tools de terceiros
- Comunidade ativa e bem documentada
- Suporte oficial da HashiCorp

## Configuração básica do GitHub Actions

### Estrutura de diretórios

```text
.github/
└── workflows/
    ├── terraform-ci.yml          # Validação e teste
    ├── terraform-deploy.yml      # Deploy para ambientes
    ├── terraform-destroy.yml     # Cleanup de recursos
    └── reusable-terraform.yml    # Workflow reutilizável
```

### Workflow básico para validação

```yaml
# .github/workflows/terraform-ci.yml
name: 'Terraform CI'

on:
  push:
    branches: [ "main", "develop" ]
  pull_request:
    branches: [ "main" ]

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest
    environment: development

    # Usar bash por padrão no Windows
    defaults:
      run:
        shell: bash

    steps:
    # Checkout do código
    - name: Checkout
      uses: actions/checkout@v4

    # Setup do Terraform
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: "1.5.0"

    # Formatação
    - name: Terraform Format
      id: fmt
      run: terraform fmt -check

    # Inicialização
    - name: Terraform Init
      id: init
      run: terraform init

    # Validação
    - name: Terraform Validate
      id: validate
      run: terraform validate -no-color

    # Planejamento
    - name: Terraform Plan
      id: plan
      if: github.event_name == 'pull_request'
      run: terraform plan -no-color -input=false
      continue-on-error: true

    # Comentário no PR com resultado do plan
    - name: Update Pull Request
      uses: actions/github-script@v7
      if: github.event_name == 'pull_request'
      env:
        PLAN: "terraform\n${{ steps.plan.outputs.stdout }}"
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}
        script: |
          const output = `#### Terraform Format and Style 🖌\`${{ steps.fmt.outcome }}\`
          #### Terraform Initialization ⚙️\`${{ steps.init.outcome }}\`
          #### Terraform Validation 🤖\`${{ steps.validate.outcome }}\`
          #### Terraform Plan 📖\`${{ steps.plan.outcome }}\`

          <details><summary>Show Plan</summary>

          \`\`\`terraform\n
          ${process.env.PLAN}
          \`\`\`

          </details>

          *Pushed by: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;

          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: output
          })

    # Status do Planeamento
    - name: Terraform Plan Status
      if: steps.plan.outcome == 'failure'
      run: exit 1

    # Apply automático (apenas na main)
    - name: Terraform Apply
      if: github.ref == 'refs/heads/main' && github.event_name == 'push'
      run: terraform apply -auto-approve -input=false
```

## Setup Terraform Action Oficial

### Funcionalidades da action oficial

A [hashicorp/setup-terraform](https://github.com/hashicorp/setup-terraform) oferece:

- **Instalação automática** do Terraform CLI
- **Wrapper script** para capturar outputs
- **Configuração de credenciais** para HCP Terraform/TFE
- **Suporte multiplataforma** (Linux, Windows, macOS)

### Configurações avançadas

```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v3
  with:
    # Versão específica ou constraint
    terraform_version: "~1.5.0"  # Latest 1.5.x
    
    # Credenciais HCP Terraform
    cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}
    
    # Hostname customizado (TFE)
    cli_config_credentials_hostname: 'terraform.company.com'
    
    # Desabilitar wrapper (se necessário)
    terraform_wrapper: false
```

### Usando outputs do wrapper

```yaml
- name: Terraform Plan
  id: plan
  run: terraform plan -no-color -out=tfplan

- name: Show Plan Output
  run: |
    echo "STDOUT: ${{ steps.plan.outputs.stdout }}"
    echo "STDERR: ${{ steps.plan.outputs.stderr }}"
    echo "EXIT CODE: ${{ steps.plan.outputs.exitcode }}"

- name: Save Plan
  uses: actions/upload-artifact@v4
  with:
    name: terraform-plan
    path: tfplan
```

## Workflows avançados para diferentes ambientes

### Multi-environment deployment

```yaml
# .github/workflows/terraform-deploy.yml
name: 'Multi-Environment Deploy'

on:
  push:
    branches: [ "main" ]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        default: 'development' 
        type: choice
        options:
        - development
        - staging
        - production

jobs:
  deploy:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: 
          - ${{ github.event.inputs.environment || 'development' }}
    
    environment: 
      name: ${{ matrix.environment }}
      url: ${{ steps.deploy.outputs.application_url }}

    defaults:
      run:
        working-directory: ./environments/${{ matrix.environment }}

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: "1.5.0"
        cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

    - name: Terraform Init
      run: terraform init
      env:
        TF_WORKSPACE: ${{ matrix.environment }}

    - name: Terraform Plan
      id: plan
      run: terraform plan -no-color -out=tfplan
      env:
        TF_VAR_environment: ${{ matrix.environment }}
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

    - name: Terraform Apply
      id: deploy
      run: |
        terraform apply -auto-approve tfplan
        echo "application_url=$(terraform output -raw application_url)" >> $GITHUB_OUTPUT
      env:
        TF_VAR_environment: ${{ matrix.environment }}
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

### Workflow com aprovação manual

```yaml
# .github/workflows/terraform-production.yml
name: 'Production Deploy'

on:
  workflow_dispatch:
  schedule:
    - cron: '0 9 * * MON'  # Segundas às 9h

jobs:
  plan:
    name: 'Terraform Plan'
    runs-on: ubuntu-latest
    environment: production-plan
    
    outputs:
      plan-exitcode: ${{ steps.plan.outputs.exitcode }}
      
    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: "1.5.0"

    - name: Terraform Init
      run: terraform init
      working-directory: ./environments/production

    - name: Terraform Plan
      id: plan
      run: terraform plan -detailed-exitcode -no-color -out=tfplan
      working-directory: ./environments/production
      continue-on-error: true

    - name: Upload Plan
      uses: actions/upload-artifact@v4
      with:
        name: terraform-plan
        path: ./environments/production/tfplan

  apply:
    name: 'Terraform Apply'
    runs-on: ubuntu-latest
    needs: plan
    if: needs.plan.outputs.plan-exitcode == '2'
    environment: 
      name: production
      url: https://app.mycompany.com
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: "1.5.0"

    - name: Download Plan
      uses: actions/download-artifact@v4
      with:
        name: terraform-plan
        path: ./environments/production

    - name: Terraform Init
      run: terraform init
      working-directory: ./environments/production

    - name: Terraform Apply
      run: terraform apply -auto-approve tfplan
      working-directory: ./environments/production
```

## Validação e qualidade de código

### Workflow completo de validação

```yaml
# .github/workflows/terraform-quality.yml
name: 'Terraform Quality Checks'

on:
  pull_request:
    branches: [ "main", "develop" ]

jobs:
  quality:
    name: 'Quality Checks'
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4
      with:
        fetch-depth: 0  # Necessário para análise de diff

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: "1.5.0"

    # Verificação de formatação
    - name: Check Terraform formatting
      run: |
        if ! terraform fmt -check -recursive .; then
          echo "❌ Terraform files need formatting"
          echo "Run: terraform fmt -recursive ."
          exit 1
        fi
        echo "✅ All Terraform files are properly formatted"

    # Validação de sintaxe em todos os diretórios
    - name: Validate Terraform configurations
      run: |
        find . -name "*.tf" -exec dirname {} \; | sort -u | while read dir; do
          echo "Validating $dir"
          cd "$dir"
          terraform init -backend=false
          terraform validate
          cd - > /dev/null
        done

    # TFLint para linting
    - name: Setup TFLint
      uses: terraform-linters/setup-tflint@v4
      with:
        tflint_version: v0.47.0

    - name: Show TFLint version
      run: tflint --version

    - name: Init TFLint
      run: tflint --init

    - name: Run TFLint
      run: tflint -f compact

    # Checkov para security scanning
    - name: Run Checkov action
      uses: bridgecrewio/checkov-action@master
      with:
        directory: .
        framework: terraform
        output_format: sarif
        output_file_path: reports/results.sarif
        quiet: true
        soft_fail: true

    # Upload de resultados do security scan
    - name: Upload SARIF file
      uses: github/codeql-action/upload-sarif@v3
      with:
        sarif_file: reports/results.sarif

    # Documentação automática
    - name: Generate terraform docs
      uses: terraform-docs/gh-actions@main
      with:
        working-dir: .
        output-file: README.md
        output-method: inject
        git-push: "true"
```

### TFSec integration

```yaml
    # TFSec security scanning
    - name: Run tfsec
      uses: aquasecurity/tfsec-action@v1.0.3
      with:
        soft_fail: true
        format: sarif
        additional_args: --out tfsec-results.sarif

    - name: Upload tfsec results
      uses: github/codeql-action/upload-sarif@v3
      with:
        sarif_file: tfsec-results.sarif
```

## Gerenciamento de secrets e credenciais

### AWS credentials

```yaml
# Method 1: AWS Access Keys
env:
  AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
  AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  AWS_DEFAULT_REGION: us-east-1

# Method 2: OIDC (Recomendado)
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789012:role/GitHubActionsRole
    aws-region: us-east-1

# Method 3: AssumeRole
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    aws-region: us-east-1
    role-to-assume: arn:aws:iam::123456789012:role/TerraformRole
    role-duration-seconds: 3600
```

### Azure credentials

```yaml
- name: Azure Login
  uses: azure/login@v1
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}

# Ou usando Service Principal
env:
  ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
  ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
  ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
  ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}
```

### Google Cloud credentials

```yaml
- name: Setup gcloud CLI
  uses: google-github-actions/setup-gcloud@v2
  with:
    service_account_key: ${{ secrets.GCP_SA_KEY }}
    project_id: ${{ secrets.GCP_PROJECT_ID }}

# Ou usando Workload Identity
- name: Authenticate to Google Cloud
  uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: 'projects/123456789/locations/global/workloadIdentityPools/my-pool/providers/my-provider'
    service_account: 'my-service-account@my-project.iam.gserviceaccount.com'
```

## Workflows reutilizáveis

### Workflow template reutilizável

```yaml
# .github/workflows/reusable-terraform.yml
name: 'Reusable Terraform Workflow'

on:
  workflow_call:
    inputs:
      terraform_version:
        description: 'Terraform version to use'
        required: false
        default: '1.5.0'
        type: string
      working_directory:
        description: 'Directory containing Terraform files'
        required: true
        type: string
      environment:
        description: 'Environment to deploy to'
        required: true
        type: string
      run_apply:
        description: 'Whether to run terraform apply'
        required: false
        default: false
        type: boolean
    secrets:
      AWS_ACCESS_KEY_ID:
        required: true
      AWS_SECRET_ACCESS_KEY:
        required: true
      TF_API_TOKEN:
        required: false

    outputs:
      plan_exitcode:
        description: 'Exit code of terraform plan'
        value: ${{ jobs.terraform.outputs.plan_exitcode }}

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment }}
    
    defaults:
      run:
        working-directory: ${{ inputs.working_directory }}

    outputs:
      plan_exitcode: ${{ steps.plan.outputs.exitcode }}

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ inputs.terraform_version }}
        cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

    - name: Terraform Init
      run: terraform init

    - name: Terraform Format
      run: terraform fmt -check

    - name: Terraform Validate
      run: terraform validate

    - name: Terraform Plan
      id: plan
      run: terraform plan -detailed-exitcode -no-color -out=tfplan
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        TF_VAR_environment: ${{ inputs.environment }}

    - name: Terraform Apply
      if: inputs.run_apply && steps.plan.outputs.exitcode == '2'
      run: terraform apply -auto-approve tfplan
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        TF_VAR_environment: ${{ inputs.environment }}
```

### Usando o workflow reutilizável

```yaml
# .github/workflows/dev-deploy.yml
name: 'Dev Environment Deploy'

on:
  push:
    branches: [ "develop" ]

jobs:
  deploy-dev:
    uses: ./.github/workflows/reusable-terraform.yml
    with:
      terraform_version: '1.5.0'
      working_directory: './environments/dev'
      environment: 'development'
      run_apply: true
    secrets:
      AWS_ACCESS_KEY_ID: ${{ secrets.DEV_AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.DEV_AWS_SECRET_ACCESS_KEY }}
      TF_API_TOKEN: ${{ secrets.TF_API_TOKEN }}
```

## Matrix builds para múltiplos ambientes

```yaml
name: 'Multi-Environment Matrix Deploy'

on:
  workflow_dispatch:
    inputs:
      environments:
        description: 'Environments to deploy (comma-separated)'
        required: true
        default: 'dev,staging'

jobs:
  deploy:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        environment: ${{ fromJson(format('["{0}"]', join(split(github.event.inputs.environments, ','), '","'))) }}
        terraform_version: ['1.4.6', '1.5.0']
        
    name: Deploy to ${{ matrix.environment }} (TF ${{ matrix.terraform_version }})
    environment: ${{ matrix.environment }}
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Setup Terraform ${{ matrix.terraform_version }}
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: ${{ matrix.terraform_version }}

    - name: Deploy to ${{ matrix.environment }}
      run: |
        cd environments/${{ matrix.environment }}
        terraform init
        terraform plan
        terraform apply -auto-approve
```

## Notificações e integrações

### Slack notifications

```yaml
    - name: Notify Slack on Success
      if: success()
      uses: 8398a7/action-slack@v3
      with:
        status: success
        channel: '#infrastructure'
        text: '✅ Terraform deployment to ${{ matrix.environment }} completed successfully!'
      env:
        SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}

    - name: Notify Slack on Failure
      if: failure()
      uses: 8398a7/action-slack@v3
      with:
        status: failure
        channel: '#infrastructure'
        text: '❌ Terraform deployment to ${{ matrix.environment }} failed!'
      env:
        SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### Microsoft Teams

```yaml
    - name: Notify Teams
      if: always()
      uses: aliencube/microsoft-teams-actions@v0.8.0
      with:
        webhook_uri: ${{ secrets.MS_TEAMS_WEBHOOK_URI }}
        title: 'Terraform Deployment Status'
        summary: 'Deployment to ${{ matrix.environment }}: ${{ job.status }}'
        text: |
          **Environment:** ${{ matrix.environment }}
          **Status:** ${{ job.status }}
          **Actor:** ${{ github.actor }}
          **Commit:** ${{ github.sha }}
```

## Monitoramento e observabilidade

### Drift detection

```yaml
# .github/workflows/terraform-drift-detection.yml
name: 'Terraform Drift Detection'

on:
  schedule:
    - cron: '0 6 * * *'  # Daily at 6 AM
  workflow_dispatch:

jobs:
  drift-detection:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        environment: [dev, staging, prod]
        
    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3

    - name: Terraform Init
      run: terraform init
      working-directory: ./environments/${{ matrix.environment }}

    - name: Terraform Plan (Drift Check)
      id: drift
      run: terraform plan -detailed-exitcode -no-color
      working-directory: ./environments/${{ matrix.environment }}
      continue-on-error: true

    - name: Report Drift
      if: steps.drift.outputs.exitcode == '2'
      run: |
        echo "🚨 Configuration drift detected in ${{ matrix.environment }}!"
        echo "Plan output:"
        echo "${{ steps.drift.outputs.stdout }}"
        
    - name: Create Issue for Drift
      if: steps.drift.outputs.exitcode == '2'
      uses: actions/github-script@v7
      with:
        script: |
          github.rest.issues.create({
            owner: context.repo.owner,
            repo: context.repo.repo,
            title: `🚨 Configuration Drift Detected - ${{ matrix.environment }}`,
            body: `## Configuration Drift Alert
            
            **Environment:** ${{ matrix.environment }}
            **Detection Time:** ${new Date().toISOString()}
            
            ### Drift Details:
            \`\`\`
            ${{ steps.drift.outputs.stdout }}
            \`\`\`
            
            Please review and address this drift as soon as possible.`,
            labels: ['infrastructure', 'drift', 'urgent']
          })
```

### Cost estimation integration

```yaml
    - name: Setup Infracost
      uses: infracost/actions/setup@v2
      with:
        api-key: ${{ secrets.INFRACOST_API_KEY }}

    - name: Generate Infracost JSON
      run: infracost breakdown --path . --format json --out-file infracost.json

    - name: Post Infracost comment
      run: |
        infracost comment github --path infracost.json \
          --repo $GITHUB_REPOSITORY \
          --github-token ${{ secrets.GITHUB_TOKEN }} \
          --pull-request ${{ github.event.pull_request.number }} \
          --behavior update
```

## Troubleshooting e debugging

### Debug logs habilitados

```yaml
env:
  ACTIONS_STEP_DEBUG: true
  ACTIONS_RUNNER_DEBUG: true
  TF_LOG: DEBUG
```

### Workflow com condicional para debug

```yaml
    - name: Debug Information
      if: runner.debug == '1'
      run: |
        echo "=== Environment Variables ==="
        env | sort
        echo "=== Terraform Version ==="
        terraform version
        echo "=== Working Directory Contents ==="
        ls -la
        echo "=== Git Information ==="
        git log -1 --oneline
```

### Artifact collection para troubleshooting

```yaml
    - name: Collect Terraform Logs
      if: failure()
      run: |
        mkdir -p logs
        cp .terraform.lock.hcl logs/ || true
        terraform show -json > logs/terraform-state.json || true
        
    - name: Upload Terraform Artifacts
      if: failure()
      uses: actions/upload-artifact@v4
      with:
        name: terraform-debug-${{ matrix.environment }}
        path: |
          logs/
          *.tfplan
          .terraform/
        retention-days: 30
```

## Self-hosted runners

### Configuração para self-hosted runner

```yaml
# .github/workflows/terraform-self-hosted.yml
name: 'Terraform with Self-Hosted Runner'

on:
  push:
    branches: [ "main" ]

jobs:
  deploy:
    runs-on: [self-hosted, linux, terraform]
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4

    # Não precisa do setup-terraform se já estiver instalado no runner
    - name: Check Terraform
      run: terraform version

    - name: Terraform Init
      run: terraform init

    - name: Terraform Apply
      run: terraform apply -auto-approve
      env:
        # Usar roles do IAM do EC2 em vez de secrets
        AWS_DEFAULT_REGION: us-east-1
```

### Labels customizadas para runners

```yaml
jobs:
  deploy-aws:
    runs-on: [self-hosted, aws, production]
    
  deploy-azure:
    runs-on: [self-hosted, azure, production]
    
  deploy-gcp:
    runs-on: [self-hosted, gcp, production]
```

## Melhores práticas para GitHub Actions + Terraform

### ✅ **Fazer**

1. **Usar versões fixas** das actions para reproducibilidade
2. **Implementar approval gates** para ambientes de produção
3. **Validar sempre** antes de aplicar
4. **Usar secrets management** adequado
5. **Implementar drift detection** automatizado
6. **Documentar workflows** claramente
7. **Usar outputs** para compartilhar dados entre jobs
8. **Implementar rollback** automático em caso de falha
9. **Monitor custos** com ferramentas como Infracost
10. **Usar workflow reutilizáveis** para evitar duplicação

### ❌ **Evitar**

1. **Hardcoded secrets** no código
2. **Auto-approve** em todos os ambientes
3. **Falta de validação** antes do apply
4. **Workflows muito complexos** sem documentação
5. **Ignorar falhas** de segurança
6. **Execução simultânea** no mesmo estado
7. **Falta de cleanup** de recursos temporários
8. **Logs de debug** em produção permanentemente
9. **Workflows sem timeout** adequado
10. **Misturar** responsabilidades em um único job

## Templates prontos para usar

### Template básico para novo projeto

```yaml
name: 'Terraform'

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

permissions:
  contents: read
  pull-requests: write

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: 1.5.0

    - name: Terraform Format
      id: fmt
      run: terraform fmt -check

    - name: Terraform Init
      id: init
      run: terraform init

    - name: Terraform Validate
      id: validate
      run: terraform validate -no-color

    - name: Terraform Plan
      id: plan
      if: github.event_name == 'pull_request'
      run: terraform plan -no-color -input=false
      continue-on-error: true

    - name: Terraform Plan Status
      if: steps.plan.outcome == 'failure'
      run: exit 1

    - name: Terraform Apply
      if: github.ref == 'refs/heads/main' && github.event_name == 'push'
      run: terraform apply -auto-approve -input=false
```

## Conclusão

O GitHub Actions oferece uma plataforma robusta e flexível para implementar CI/CD com Terraform. A integração nativa com o GitHub, combined com a action oficial da HashiCorp e o ecossistema rico de ferramentas disponíveis, permite criar pipelines sofisticados que atendem desde projetos simples até arquiteturas enterprise complexas.

As práticas apresentadas neste guia garantem:

- **Deployments seguros e auditáveis**
- **Validação automática** de qualidade e segurança
- **Colaboração eficiente** através de Pull Requests
- **Escalabilidade** para múltiplos ambientes e equipes
- **Observabilidade** e monitoramento contínuo

Comece com workflows simples e evolua gradualmente, incorporando validações, aprovações e monitoramento conforme sua equipe ganha experiência e confiança no processo.

## Recursos Adicionais

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [HashiCorp Setup Terraform Action](https://github.com/hashicorp/setup-terraform)
- [Terraform Automation Tutorial](https://developer.hashicorp.com/terraform/tutorials/automation/github-actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

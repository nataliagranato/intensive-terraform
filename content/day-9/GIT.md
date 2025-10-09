# Git para Projetos Terraform: Workflows e Melhores Práticas

![Git workflow](https://git-scm.com/images/logos/downloads/Git-Logo-2Color.png)

O controle de versão é fundamental para o sucesso de qualquer projeto de infraestrutura como código. Este guia aborda as melhores práticas para usar Git com Terraform, incluindo estratégias de branching, workflows colaborativos e padrões específicos para gerenciar infraestrutura.

## Por que Git é crucial para Terraform?

### 1. **Rastreabilidade completa**
- Histórico detalhado de todas as mudanças na infraestrutura
- Capacidade de reverter alterações problemáticas
- Auditoria e compliance facilitados

### 2. **Colaboração segura**
- Múltiplos desenvolvedores trabalhando na mesma infraestrutura
- Revisão de código antes da aplicação
- Controle de acesso granular

### 3. **Integração com CI/CD**
- Automação de deploys baseada em commits
- Testes automatizados de configurações
- Ambientes isolados por branch

### 4. **Gerenciamento de estado**
- Coordenação de mudanças no state file
- Prevenção de conflitos de estado
- Backup automático através do histórico

## Estrutura de repositório para Terraform

### Estrutura recomendada

```text
terraform-infrastructure/
├── .gitignore                    # Arquivos a serem ignorados
├── .terraform-docs.yml           # Configuração para documentação
├── README.md                     # Documentação principal
├── versions.tf                   # Versões do Terraform e providers
├── environments/                 # Configurações por ambiente
│   ├── dev/
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   └── prod/
│       ├── main.tf
│       ├── terraform.tfvars
│       └── backend.tf
├── modules/                      # Módulos reutilizáveis
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── rds/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
├── scripts/                      # Scripts auxiliares
│   ├── deploy.sh
│   ├── validate.sh
│   └── cleanup.sh
└── docs/                         # Documentação adicional
    ├── architecture.md
    └── deployment.md
```

### .gitignore essencial para Terraform

```bash
# .gitignore para projetos Terraform

# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files, which are likely to contain sensitive data
*.tfvars
*.tfvars.json

# Ignore override files as they are usually used to override resources locally
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Include override files you do wish to add to version control using negation
# The following would include override files with a priority higher than the overrides:
# !override.tf
# !*_override.tf

# Include tfplan files to ignore the plan output of command: terraform plan -out=tfplan
*tfplan*

# Ignore CLI configuration files
.terraformrc
terraform.rc

# Ignore Mac .DS_Store files
.DS_Store

# Ignore editor-specific files
*.swp
*.swo
*~

# Ignore log files
*.log

# Ignore temporary files
*.tmp
*.temp

# IDE-specific files
.vscode/
.idea/
*.iml

# OS-specific files
Thumbs.db
```

## Estratégias de Branching para Terraform

### 1. **GitFlow para Infraestrutura**

```text
main (prod)         ●─────●─────●─────●
                   /             \
develop           ●─●─●─●─●─●─●─●─●─●
                 /   /         \   \
feature/vpc     ●─●─●           \   \
                               \   \
hotfix/security                 ●─●─●
```

**Branches principais:**
- `main`: Código em produção
- `develop`: Integração de features
- `feature/*`: Desenvolvimento de funcionalidades
- `hotfix/*`: Correções urgentes
- `release/*`: Preparação para release

**Exemplo de workflow:**

```bash
# Criar feature branch
git checkout develop
git pull origin develop
git checkout -b feature/add-vpc-module

# Desenvolver funcionalidade
# ... editar arquivos terraform ...
git add .
git commit -m "feat: add VPC module with subnet configuration"

# Push e criar Pull Request
git push origin feature/add-vpc-module
# Abrir PR de feature/add-vpc-module -> develop

# Após aprovação, merge para develop
# Testar em ambiente de desenvolvimento

# Criar release branch
git checkout develop
git pull origin develop
git checkout -b release/v1.2.0

# Preparar release (atualizações de versão, docs)
git add .
git commit -m "chore: prepare release v1.2.0"

# Merge para main e develop
git checkout main
git merge release/v1.2.0
git tag v1.2.0
git push origin main --tags

git checkout develop
git merge release/v1.2.0
git push origin develop
```

### 2. **GitHub Flow (Simplificado)**

```text
main              ●─────●─────●─────●
                 /     /     /     /
feature-1       ●─●─●─●     /     /
                           /     /
feature-2                ●─●─●─●
                               /
hotfix                       ●─●
```

**Mais simples para equipes menores:**

```bash
# Criar feature branch direto da main
git checkout main
git pull origin main
git checkout -b feature/add-security-groups

# Desenvolver e committar
git add .
git commit -m "feat: add security groups for web tier"

# Push e PR direto para main
git push origin feature/add-security-groups
# Abrir PR de feature/add-security-groups -> main
```

### 3. **Environment Branching**

```text
prod              ●─────●─────●─────●
                 /     /     /     /
staging         ●─●─●─●─●─●─●─●─●─●
               /     /     /     /
dev           ●─●─●─●─●─●─●─●─●─●─●
             /   /   /   /   /
features    ●─●   ●─●   ●─●   ●─●
```

**Branch por ambiente:**
- `prod`: Configuração de produção
- `staging`: Configuração de staging
- `dev`: Configuração de desenvolvimento
- `feature/*`: Funcionalidades específicas

## Padrões de Commit para Terraform

### Conventional Commits

```bash
# Tipos de commit
feat:     # Nova funcionalidade
fix:      # Correção de bug
docs:     # Documentação
style:    # Formatação
refactor: # Refatoração
test:     # Testes
chore:    # Tarefas de manutenção
perf:     # Melhorias de performance
ci:       # Mudanças em CI/CD
```

### Exemplos práticos

```bash
# Adição de novos recursos
git commit -m "feat(vpc): add VPC module with public/private subnets"
git commit -m "feat(ec2): add auto-scaling group configuration"
git commit -m "feat(rds): add PostgreSQL RDS instance with backup"

# Correções
git commit -m "fix(security): update security group rules for HTTPS"
git commit -m "fix(networking): correct CIDR block overlap issue"

# Infraestrutura
git commit -m "chore(terraform): upgrade provider versions"
git commit -m "ci(github): add terraform validation workflow"

# Documentação
git commit -m "docs(readme): add deployment instructions"
git commit -m "docs(modules): update VPC module documentation"

# Refatoração
git commit -m "refactor(modules): split monolithic module into components"
git commit -m "refactor(variables): standardize variable naming convention"
```

## Workflows específicos para Terraform

### 1. **Workflow de Review para Mudanças Críticas**

```bash
# 1. Criar branch para mudança crítica
git checkout -b hotfix/fix-security-vulnerability

# 2. Implementar correção
terraform plan -out=security-fix.tfplan
# Revisar plan cuidadosamente

# 3. Commit com detalhamento
git add .
git commit -m "fix(security): patch critical vulnerability in security groups

- Update ingress rules to restrict SSH access
- Add explicit deny rules for sensitive ports
- Update documentation with security guidelines

Fixes: #SECURITY-001"

# 4. Push e PR com reviewers obrigatórios
git push origin hotfix/fix-security-vulnerability
# Criar PR com pelo menos 2 reviewers aprovados
```

### 2. **Workflow para Novos Ambientes**

```bash
# 1. Criar branch de ambiente
git checkout main
git checkout -b environment/new-region-setup

# 2. Copiar configuração base
cp -r environments/prod environments/us-west-2

# 3. Adaptar configurações
cd environments/us-west-2
# Editar terraform.tfvars, backend.tf, etc.

# 4. Validar configuração
terraform init
terraform validate
terraform plan

# 5. Commit estruturado
git add .
git commit -m "feat(environments): add us-west-2 production environment

- Copy base configuration from existing prod environment
- Update region-specific variables and backend config
- Configure provider aliases for multi-region deployment
- Add environment-specific networking configuration

Environment: us-west-2
Impact: New region deployment capability"
```

### 3. **Workflow de Versionamento de Módulos**

```bash
# 1. Desenvolver módulo
git checkout -b module/vpc-v2.0

# 2. Implementar mudanças
cd modules/vpc
# Desenvolver nova versão do módulo

# 3. Atualizar documentação
terraform-docs markdown table . > README.md

# 4. Commit com breaking changes
git add .
git commit -m "feat(vpc)!: upgrade VPC module to v2.0

BREAKING CHANGES:
- Subnet naming convention changed from snake_case to kebab-case
- Default CIDR blocks updated to avoid conflicts
- Removed deprecated variables: enable_dns_hostnames_legacy

Migration guide:
- Update subnet references in existing configurations
- Replace deprecated variables with new equivalents
- Review CIDR allocations for potential conflicts"

# 5. Tag de versão
git tag -a v2.0.0 -m "VPC Module v2.0.0 - Major update with breaking changes"
git push origin v2.0.0
```

## Estratégias de Merge

### 1. **Merge Commit (Recomendado para features grandes)**

```bash
# Preserva histórico completo
git checkout main
git merge --no-ff feature/major-infrastructure-update

# Resultado:
#   A---B---C feature/major-infrastructure-update
#  /         \
# D-----------M main
```

### 2. **Squash Merge (Para features simples)**

```bash
# Condensa múltiplos commits em um
git checkout main
git merge --squash feature/simple-config-update
git commit -m "feat: update ELB configuration for better health checks"

# Resultado:
# D---E main (E contém todas as mudanças de A, B, C)
```

### 3. **Rebase (Para histórico linear)**

```bash
# Reescreve histórico para ficar linear
git checkout feature/update-security-groups
git rebase main
git checkout main
git merge feature/update-security-groups

# Resultado:
# D---A'---B'---C' main (commits reescritos sobre main)
```

## Segurança e Sensibilidade

### 1. **Gerenciamento de Segredos**

```bash
# NUNCA commitar secrets diretamente
# ❌ Errado
aws_access_key = "AKIA123456789"
db_password = "super-secret-password"

# ✅ Correto - usar variáveis
variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
```

### 2. **Arquivo .tfvars seguro**

```bash
# terraform.tfvars (não commitado)
aws_access_key = "AKIA123456789"
db_password = "super-secret-password"

# terraform.tfvars.example (commitado como template)
aws_access_key = "your-aws-access-key"
db_password = "your-database-password"
```

### 3. **Git secrets prevention**

```bash
# Instalar git-secrets
git secrets --install
git secrets --register-aws

# Prevenir commits com secrets
git secrets --scan
```

## Hooks do Git para Terraform

### 1. **Pre-commit hook**

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running Terraform validations..."

# Validar formatação
if ! terraform fmt -check=true -diff=true; then
    echo "❌ Terraform files need formatting. Run: terraform fmt"
    exit 1
fi

# Validar sintaxe
for dir in environments/*/; do
    echo "Validating $dir..."
    cd "$dir"
    if ! terraform validate; then
        echo "❌ Terraform validation failed in $dir"
        exit 1
    fi
    cd - > /dev/null
done

# Validar com checkov (se instalado)
if command -v checkov >/dev/null 2>&1; then
    echo "Running Checkov security scan..."
    if ! checkov -d . --framework terraform; then
        echo "❌ Security scan failed"
        exit 1
    fi
fi

echo "✅ All validations passed!"
```

### 2. **Pre-push hook**

```bash
#!/bin/bash
# .git/hooks/pre-push

protected_branch='main'
current_branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

if [ $protected_branch = $current_branch ]; then
    echo "❌ Direct push to main branch is not allowed"
    echo "Please create a pull request instead"
    exit 1
fi

echo "✅ Push allowed to $current_branch"
```

## Integração com Ferramentas

### 1. **Pre-commit framework**

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-json

  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.5
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
      - id: terraform_tflint
      - id: checkov
```

### 2. **GitHub Actions para validação**

```yaml
# .github/workflows/terraform-validation.yml
name: Terraform Validation

on:
  pull_request:
    branches: [ main, develop ]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: 1.5.0
    
    - name: Terraform Format Check
      run: terraform fmt -check -recursive
    
    - name: Terraform Validate
      run: |
        for dir in environments/*/; do
          echo "Validating $dir"
          cd "$dir"
          terraform init -backend=false
          terraform validate
          cd - > /dev/null
        done
    
    - name: Security Scan
      uses: bridgecrewio/checkov-action@master
      with:
        directory: .
        framework: terraform
```

## Resolução de Conflitos

### 1. **Conflitos em arquivos .tf**

```bash
# Quando há conflito, Git marca assim:
resource "aws_instance" "web" {
  instance_type = "t3.micro"
<<<<<<< HEAD
  ami = "ami-12345678"  # Versão do seu branch
=======
  ami = "ami-87654321"  # Versão do branch sendo merged
>>>>>>> feature/update-ami
  
  tags = {
    Name = "WebServer"
  }
}

# Resolução manual:
resource "aws_instance" "web" {
  instance_type = "t3.micro"
  ami = "ami-87654321"  # Escolher a versão correta
  
  tags = {
    Name = "WebServer"
  }
}
```

### 2. **Conflitos em terraform.tfstate (evitar)**

```bash
# NUNCA commitar terraform.tfstate
# Usar remote backend para evitar conflitos

# backend.tf
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "environments/prod/terraform.tfstate"
    region = "us-east-1"
    
    # Locking
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

## Estratégias de Release

### 1. **Semantic Versioning para Infraestrutura**

```bash
# Versioning scheme: MAJOR.MINOR.PATCH
# v1.2.3

# MAJOR: Breaking changes (incompatível)
# - Mudanças que requerem recreação de recursos
# - Alterações em interfaces públicas de módulos
# - Atualizações de provider com breaking changes

# MINOR: New features (compatível)  
# - Novos recursos ou funcionalidades
# - Novos outputs ou variáveis opcionais
# - Melhorias que mantêm compatibilidade

# PATCH: Bug fixes (compatível)
# - Correções de bugs
# - Atualizações de documentação
# - Pequenas melhorias sem impacto funcional
```

### 2. **Release workflow**

```bash
# 1. Preparar release
git checkout develop
git pull origin develop
git checkout -b release/v1.3.0

# 2. Atualizar versões
# Atualizar versions.tf, CHANGELOG.md, README.md

# 3. Commit de preparação
git add .
git commit -m "chore: prepare release v1.3.0

- Update terraform and provider versions
- Update CHANGELOG with new features and fixes
- Update README with new examples"

# 4. Merge para main
git checkout main
git merge --no-ff release/v1.3.0

# 5. Tag de release
git tag -a v1.3.0 -m "Release v1.3.0

Features:
- Add support for multiple availability zones
- New RDS module with automated backups
- Enhanced security group configurations

Bug fixes:
- Fix subnet CIDR calculation
- Resolve provider version conflicts

Breaking changes: None"

git push origin main --tags

# 6. Merge back para develop
git checkout develop
git merge main
git push origin develop

# 7. Cleanup
git branch -d release/v1.3.0
```

## Melhores Práticas Resumidas

### ✅ **Fazer**

1. **Usar .gitignore completo** para Terraform
2. **Estrutura consistente** de diretórios
3. **Commits semânticos** e descritivos
4. **Branches feature** para mudanças
5. **Pull Requests** obrigatórios para main/prod
6. **Validação automática** em PRs
7. **Documentação** sempre atualizada
8. **Tags de versão** para releases
9. **Remote backend** para state files
10. **Hooks de validação** locais

### ❌ **Evitar**

1. **Commitar** arquivos `.tfstate`
2. **Secrets em plain text** no código
3. **Push direto** para branches protegidas  
4. **Commits grandes** sem descrição
5. **Branches** de longa duração sem merge
6. **Conflitos de state** por falta de coordenação
7. **Validação** apenas em produção
8. **Documentação** desatualizada
9. **Force push** em branches compartilhadas
10. **Misturar** ambientes no mesmo branch

## Conclusão

O Git é uma ferramenta poderosa para gerenciar código Terraform, mas requer práticas específicas para infraestrutura como código. A implementação dessas estratégias garante:

- **Colaboração segura** entre equipes
- **Deployments previsíveis** e auditáveis  
- **Recuperação rápida** de problemas
- **Escalabilidade** para projetos grandes
- **Compliance** com padrões organizacionais

Escolha as estratégias que melhor se adequam ao tamanho da sua equipe e complexidade do projeto, implementando gradualmente conforme a maturidade da equipe cresce.

## Recursos Adicionais

- [Git Documentation](https://git-scm.com/doc)
- [Terraform Best Practices](https://developer.hashicorp.com/terraform/cloud-docs/recommended-practices)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Pre-commit Framework](https://pre-commit.com/)
- [GitFlow Workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)

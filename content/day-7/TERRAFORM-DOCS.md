# Terraform-docs: Documentação Automática para Módulos Terraform

![Terraform-docs](https://terraform-docs.io/images/teaser.png)

O [terraform-docs](https://terraform-docs.io/) é uma ferramenta utilitária que gera documentação automaticamente a partir de módulos Terraform em vários formatos de saída. Desenvolvida para facilitar a manutenção de documentação consistente e atualizada, ela extrai informações diretamente do código Terraform e as apresenta em formatos legíveis e padronizados.

## O que é o terraform-docs?

O terraform-docs é uma ferramenta de linha de comando que analisa código Terraform e gera documentação automática incluindo:

- **Providers**: Provedores utilizados no módulo
- **Requirements**: Versões mínimas necessárias
- **Inputs**: Variáveis de entrada com tipos, descrições e valores padrão
- **Outputs**: Saídas do módulo com descrições
- **Resources**: Recursos criados pelo módulo
- **Data sources**: Fontes de dados utilizadas
- **Modules**: Submódulos chamados

## Por que usar o terraform-docs?

### 1. **Documentação sempre atualizada**
- Gera documentação diretamente do código fonte
- Elimina a dessincronia entre código e documentação
- Atualização automática a cada mudança

### 2. **Padronização**
- Formato consistente em todos os módulos
- Templates customizáveis para diferentes necessidades
- Múltiplos formatos de saída disponíveis

### 3. **Integração com workflows**
- Execução via CI/CD pipelines
- Hooks de pre-commit para automatização
- Configuração centralizada via arquivos YAML

### 4. **Facilita colaboração**
- README gerado automaticamente
- Documentação clara para novos membros da equipe
- Especificações técnicas sempre atuais

## Instalação

### macOS (Homebrew)

```bash
# Instalação via Homebrew
brew install terraform-docs

# Ou usando o tap oficial
brew install terraform-docs/tap/terraform-docs
```

### Windows

**Scoop:**
```bash
scoop bucket add terraform-docs https://github.com/terraform-docs/scoop-bucket
scoop install terraform-docs
```

**Chocolatey:**
```bash
choco install terraform-docs
```

### Linux/Unix (Binary pré-compilado)

```bash
# Download da versão mais recente
curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.20.0/terraform-docs-v0.20.0-$(uname)-amd64.tar.gz

# Extração e instalação
tar -xzf terraform-docs.tar.gz
chmod +x terraform-docs
sudo mv terraform-docs /usr/local/bin/terraform-docs
```

### Docker

```bash
# Executar em um diretório com arquivos .tf
docker run --rm --volume "$(pwd):/terraform-docs" \
  -u $(id -u) quay.io/terraform-docs/terraform-docs:0.20.0 \
  markdown /terraform-docs
```

### Go Install

```bash
# Go 1.17+
go install github.com/terraform-docs/terraform-docs@v0.20.0

# Go 1.16
GO111MODULE="on" go get github.com/terraform-docs/terraform-docs@v0.20.0
```

## Uso básico

### Comando simples

```bash
# Gerar documentação em markdown para o diretório atual
terraform-docs markdown .

# Gerar documentação para um módulo específico
terraform-docs markdown ./modules/vpc

# Gerar em formato de tabela markdown
terraform-docs markdown table ./modules/vpc
```

### Principais formatos de saída

```bash
# Markdown table (mais popular)
terraform-docs markdown table .

# JSON
terraform-docs json .

# YAML
terraform-docs yaml .

# Documento Markdown completo
terraform-docs markdown document .

# Pretty (formato legível)
terraform-docs pretty .

# AsciiDoc
terraform-docs asciidoc .
```

## Exemplo prático

Considere este módulo Terraform simples:

```hcl
# variables.tf
variable "environment" {
  description = "Ambiente de deployment (dev, staging, prod)"
  type        = string
  validation {
    condition     = can(regex("^(dev|staging|prod)$", var.environment))
    error_message = "Environment deve ser: dev, staging ou prod."
  }
}

variable "vpc_cidr" {
  description = "Bloco CIDR para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "Habilitar DNS hostnames na VPC"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags adicionais para os recursos"
  type        = map(string)
  default     = {}
}

# main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  })
}

data "aws_availability_zones" "available" {
  state = "available"
}

# outputs.tf
output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "Bloco CIDR da VPC"
  value       = aws_vpc.main.cidr_block
}

output "availability_zones" {
  description = "Zonas de disponibilidade disponíveis"
  value       = data.aws_availability_zones.available.names
}
```

### Executando terraform-docs:

```bash
terraform-docs markdown table .
```

**Resultado gerado:**

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Ambiente de deployment (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Habilitar DNS hostnames na VPC | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags adicionais para os recursos | `map(string)` | `{}` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | Bloco CIDR para a VPC | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | Zonas de disponibilidade disponíveis |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | Bloco CIDR da VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID da VPC criada |

## Configuração avançada

### Arquivo .terraform-docs.yml

Para execução consistente e configuração compartilhada, crie um arquivo `.terraform-docs.yml`:

```yaml
# .terraform-docs.yml
formatter: "markdown table"

version: "~> 1.0"

header-from: "main.tf"
footer-from: ""

recursive:
  enabled: true
  path: modules
  include-main: true

sections:
  hide: []
  show: []

content: ""

output:
  file: "README.md"
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->

output-values:
  enabled: false
  from: ""

sort:
  enabled: true
  by: name

settings:
  anchor: true
  color: true
  default: true
  description: false
  escape: true
  hide-empty: false
  html: true
  indent: 2
  lockfile: true
  read-comments: true
  required: true
  sensitive: true
  type: true
```

### Execução com configuração

```bash
# Usa automaticamente .terraform-docs.yml
terraform-docs .

# Ou especifica arquivo de configuração customizado
terraform-docs -c .tfdocs-config.yml .
```

## Automatização

### Pre-commit Hook

Instale o hook para gerar documentação automaticamente antes de cada commit:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/terraform-docs/terraform-docs
    rev: "v0.20.0"
    hooks:
      - id: terraform-docs-go
        args: ['markdown', 'table', '--output-file', 'README.md']
```

### GitHub Actions

```yaml
# .github/workflows/terraform-docs.yml
name: Generate terraform docs
on:
  - pull_request

jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
      with:
        ref: ${{ github.event.pull_request.head.ref }}

    - name: Render terraform docs and push changes back to PR
      uses: terraform-docs/gh-actions@main
      with:
        working-dir: .
        output-file: README.md
        output-method: inject
        git-push: "true"
```

### Makefile para automação

```makefile
# Makefile
.PHONY: docs
docs:
	@echo "Generating documentation..."
	@terraform-docs markdown table . > README.md
	@echo "Documentation generated successfully!"

.PHONY: docs-check
docs-check:
	@echo "Checking if documentation is up to date..."
	@terraform-docs markdown table . > README.tmp
	@diff README.md README.tmp || (echo "Documentation is out of date! Run 'make docs'" && rm README.tmp && exit 1)
	@rm README.tmp
	@echo "Documentation is up to date!"
```

## Formatos de saída disponíveis

### 1. Markdown Table (mais popular)
```bash
terraform-docs markdown table .
```
Ideal para README de módulos, apresentação limpa e organizada.

### 2. Markdown Document
```bash
terraform-docs markdown document .
```
Documentação completa em markdown com headers e seções detalhadas.

### 3. JSON
```bash
terraform-docs json .
```
Saída estruturada para processamento programático.

### 4. YAML
```bash
terraform-docs yaml .
```
Formato YAML para integração with outras ferramentas.

### 5. XML
```bash
terraform-docs xml .
```
Formato XML para sistemas que requerem este formato.

### 6. AsciiDoc
```bash
terraform-docs asciidoc table .
```
Para documentação técnica avançada.

### 7. Pretty
```bash
terraform-docs pretty .
```
Formato legível para visualização rápida no terminal.

## Customização avançada

### Templates personalizados

Crie um template customizado para sua organização:

```yaml
# .terraform-docs.yml
formatter: "markdown"

content: |-
  # {{ .Header }}
  
  {{ .Providers }}
  
  ## Descrição
  
  Este módulo cria {{ .Description }}.
  
  ## Uso
  
  ```hcl
  module "exemplo" {
    source = "./modules/{{ .ModuleName }}"
    
    # Variáveis obrigatórias
    {{- range .Requirements }}
    {{ .Name }} = "valor"
    {{- end }}
  }
  ```
  
  {{ .Requirements }}
  {{ .Inputs }}
  {{ .Outputs }}
  
  ## Recursos criados
  
  {{ .Resources }}
```

### Filtragem de seções

```yaml
# .terraform-docs.yml
sections:
  show:
    - requirements
    - inputs
    - outputs
  hide:
    - providers
    - resources
```

### Ordenação customizada

```yaml
# .terraform-docs.yml
sort:
  enabled: true
  by: required  # ou 'name', 'type'
```

## Integração com CI/CD

### GitLab CI

```yaml
# .gitlab-ci.yml
terraform-docs:
  stage: validate
  image: quay.io/terraform-docs/terraform-docs:latest
  script:
    - terraform-docs markdown table . > README.tmp
    - |
      if ! diff README.md README.tmp > /dev/null; then
        echo "Documentation is out of date!"
        echo "Please run: terraform-docs markdown table . > README.md"
        exit 1
      fi
  rules:
    - if: '$CI_PIPELINE_SOURCE == "merge_request_event"'
```

### Azure DevOps

```yaml
# azure-pipelines.yml
- task: Bash@3
  displayName: 'Check Terraform Documentation'
  inputs:
    targetType: 'inline'
    script: |
      # Install terraform-docs
      curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.20.0/terraform-docs-v0.20.0-linux-amd64.tar.gz
      tar -xzf terraform-docs.tar.gz
      chmod +x terraform-docs
      
      # Generate and check documentation
      ./terraform-docs markdown table . > README.tmp
      if ! diff README.md README.tmp; then
        echo "##vso[task.logissue type=error]Documentation is out of date!"
        exit 1
      fi
```

## Melhores práticas

### 1. **Use descrições claras e detalhadas**

```hcl
variable "vpc_cidr" {
  description = <<-EOT
    Bloco CIDR para a VPC. Deve ser um bloco IPv4 válido no formato CIDR.
    Exemplo: '10.0.0.0/16' para uma VPC com 65,536 endereços IP.
    Evite sobrepor com outras VPCs ou redes on-premises.
  EOT
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR deve ser um bloco CIDR IPv4 válido."
  }
}
```

### 2. **Organize variáveis logicamente**

```hcl
# Variáveis obrigatórias primeiro
variable "environment" {
  description = "Ambiente de deployment"
  type        = string
}

# Depois variáveis com padrões
variable "vpc_cidr" {
  description = "Bloco CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Variáveis opcionais por último
variable "tags" {
  description = "Tags adicionais"
  type        = map(string)
  default     = {}
}
```

### 3. **Configure saída automática no README**

```yaml
# .terraform-docs.yml
output:
  file: "README.md"
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->
```

### 4. **Use validação consistente**

```bash
# Script de validação
#!/bin/bash
set -e

echo "Validando documentação..."
terraform-docs markdown table . > README.tmp

if ! diff README.md README.tmp > /dev/null; then
  echo "❌ Documentação desatualizada!"
  echo "Execute: terraform-docs markdown table . > README.md"
  rm README.tmp
  exit 1
else
  echo "✅ Documentação está atualizada!"
  rm README.tmp
fi
```

### 5. **Automatize com hooks**

```bash
# .git/hooks/pre-commit
#!/bin/bash

# Gera documentação automaticamente
terraform-docs markdown table . > README.md

# Adiciona ao commit se houve mudanças
if ! git diff --quiet README.md; then
  git add README.md
  echo "📝 Documentação atualizada automaticamente"
fi
```

## Compatibilidade

| terraform-docs | Terraform |
|----------------|-----------|
| >= 0.15        | >= 0.13   |
| >= 0.12, < 0.15 | >= 0.8, < 0.13 |
| < 0.12         | < 0.8     |

## Exemplos de uso em projetos reais

### Estrutura de projeto com múltiplos módulos

```
projeto-terraform/
├── .terraform-docs.yml          # Configuração global
├── README.md                    # Documentação principal
├── modules/
│   ├── vpc/
│   │   ├── .terraform-docs.yml  # Configuração específica do módulo
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md            # Gerado automaticamente
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md            # Gerado automaticamente
│   └── rds/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md            # Gerado automaticamente
└── environments/
    ├── dev/
    ├── staging/
    └── prod/
```

### Comando para documentar todos os módulos

```bash
# Documentar recursivamente todos os módulos
terraform-docs markdown table --recursive .

# Ou usar configuração específica
find . -name "*.tf" -exec dirname {} \; | sort -u | while read dir; do
  echo "Documentando: $dir"
  terraform-docs markdown table "$dir" > "$dir/README.md"
done
```

## Troubleshooting

### Problemas comuns

**1. Arquivo de configuração não encontrado:**
```bash
# Verificar se o arquivo está no local correto
ls -la .terraform-docs*

# Usar caminho absoluto
terraform-docs -c /caminho/completo/.terraform-docs.yml .
```

**2. Documentação não é injetada no README:**
```yaml
# Verificar se os marcadores estão presentes no README.md
output:
  mode: inject
  template: |-
    <!-- BEGIN_TF_DOCS -->
    {{ .Content }}
    <!-- END_TF_DOCS -->
```

**3. Erro de permissão no Docker:**
```bash
# Usar o UID correto
docker run --rm --volume "$(pwd):/terraform-docs" \
  -u $(id -u):$(id -g) \
  quay.io/terraform-docs/terraform-docs:latest \
  markdown table /terraform-docs
```

## Vantagens do terraform-docs

1. **Eliminação de trabalho manual**: Documentação gerada automaticamente
2. **Consistência**: Formato padronizado em todos os módulos  
3. **Atualização automática**: Sempre sincronizada com o código
4. **Múltiplos formatos**: Flexibilidade para diferentes necessidades
5. **Integração**: Funciona perfeitamente em pipelines CI/CD
6. **Configurabilidade**: Templates e configurações customizáveis
7. **Comunidade ativa**: Bem mantido e documentado

## Conclusão

O terraform-docs é uma ferramenta essencial para manter documentação de módulos Terraform atualizada e consistente. Sua capacidade de integração com workflows de desenvolvimento moderno e a variedade de formatos de saída fazem dela uma escolha obrigatória para equipes que trabalham com infraestrutura como código.

A automatização da documentação não apenas economiza tempo, mas também garante que a documentação permaneça precisa e útil para todos os membros da equipe, contribuindo para melhor colaboração e manutenibilidade dos projetos Terraform.

## Recursos adicionais

- [Documentação oficial](https://terraform-docs.io/)
- [Repositório no GitHub](https://github.com/terraform-docs/terraform-docs)
- [Canal Slack](https://slack.terraform-docs.io/)
- [Exemplos de configuração](https://terraform-docs.io/user-guide/configuration/)
- [Lista completa de formatos](https://terraform-docs.io/reference/terraform-docs/)

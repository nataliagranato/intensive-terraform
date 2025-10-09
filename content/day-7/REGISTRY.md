# O que é o Terraform Registry?

O [Terraform Registry](https://registry.terraform.io/) é um repositório oficial mantido pela HashiCorp que hospeda módulos e provedores reutilizáveis para o Terraform. Ele facilita a descoberta, o compartilhamento e a utilização de módulos e provedores criados pela comunidade e por fornecedores oficiais.

## Por que usar o Terraform Registry?

Usar o Terraform Registry oferece vários benefícios:
- **Reutilização de código**: Permite que você reutilize módulos e provedores existentes, economizando tempo e esforço na criação de infraestrutura.
- 
- **Qualidade e Confiabilidade**: Muitos módulos no Registry são mantidos por especialistas e passam por revisões da comunidade, garantindo um certo nível de qualidade.
- 
- **Facilidade de uso**: A integração com o Terraform é direta, facilitando a adição de módulos e provedores ao seu projeto.
- 
- **Documentação**: Muitos módulos vêm com documentação detalhada, exemplos de uso e melhores práticas.

# Como publicar um módulo no Terraform Registry?

Publicar um módulo no Terraform Registry é um processo direto que permite compartilhar módulos reutilizáveis com a comunidade. Aqui estão os requisitos e passos necessários:

## Requisitos para publicação

Antes de publicar um módulo no Registry público, você deve atender aos seguintes requisitos:

### 1. **Repositório no GitHub**

- O módulo deve estar hospedado em um repositório **público** no GitHub
- Este é um requisito apenas para o registry público - registries privados podem usar outros provedores Git

### 2. **Convenção de nomenclatura**

- O repositório deve seguir o formato: `terraform-<PROVIDER>-<NAME>`
- `<PROVIDER>`: O provedor principal onde o módulo cria recursos (ex: `aws`, `google`, `azure`)
- `<NAME>`: Tipo de infraestrutura que o módulo gerencia (pode conter hífens adicionais)
- **Exemplos**: `terraform-aws-vpc`, `terraform-google-vault`, `terraform-aws-ec2-instance`

### 3. **Descrição do repositório**

- A descrição do repositório GitHub será usada como descrição curta do módulo
- Deve ser uma descrição simples e clara em uma frase

### 4. **Estrutura padrão do módulo**

O módulo deve seguir a [estrutura padrão](https://developer.hashicorp.com/terraform/language/modules/develop/structure) recomendada:

```text
terraform-exemplo-modulo/
├── README.md
├── LICENSE
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── examples/
│   ├── basic/
│   │   └── main.tf
│   └── advanced/
│       └── main.tf
└── modules/
    └── submodule/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

**Arquivos obrigatórios**:

- `main.tf`: Ponto de entrada principal do módulo
- `variables.tf`: Declarações de variáveis de entrada
- `outputs.tf`: Declarações de saídas do módulo
- `README.md`: Documentação do módulo

**Arquivos recomendados**:

- `versions.tf`: Especifica versões do Terraform e provedores
- `LICENSE`: Licença do módulo
- `examples/`: Exemplos de uso do módulo
- `modules/`: Submódulos para funcionalidades específicas

### 5. **Tags de versionamento semântico**

- Use tags Git seguindo o [versionamento semântico](http://semver.org/)
- Formato aceito: `x.y.z` (ex: `1.0.4`) ou com prefixo `v` (ex: `v1.0.4`)
- Pelo menos uma tag de release deve existir antes da publicação
- Tags que não seguem o formato de versão são ignoradas

### 6. **Documentação das variáveis e outputs**

- Todas as variáveis e outputs devem ter descrições claras
- Essas descrições são usadas para gerar documentação automaticamente

## Processo de publicação

### 1. **Preparar o módulo**

- Certifique-se de que todos os requisitos acima foram atendidos
- Teste o módulo localmente
- Crie pelo menos uma tag de versão no repositório

### 2. **Publicar no Registry**

- Acesse o [Terraform Registry](https://registry.terraform.io/)
- Clique em "Upload" na navegação superior
- Faça login com sua conta GitHub (será solicitado acesso apenas a repositórios públicos)
- Selecione o repositório que deseja publicar na lista filtrada
- Clique em "Publish Module"

O módulo será criado em alguns segundos e estará disponível para uso pela comunidade.

## Liberando novas versões

Para liberar uma nova versão do seu módulo:

1. **Faça as alterações necessárias** no código
2. **Crie e envie uma nova tag** com formato de versão semântica:

   ```bash
   git tag v1.1.0
   git push origin v1.1.0
   ```

3. **O webhook notificará automaticamente** o Registry
4. **A nova versão aparecerá** no Registry em menos de um minuto

Se a versão não aparecer automaticamente, você pode forçar uma sincronização:

- Vá até a página do seu módulo no Registry
- Clique em "Resync Module" no menu "Manage Module"

## Removendo conteúdo publicado

Proprietários de módulos podem remover versões específicas ou o módulo inteiro através do Registry. Porém, a HashiCorp **não recomenda remover conteúdo** a menos que contenha falhas críticas, pois isso pode quebrar configurações existentes que dependem do módulo.

## Exemplo prático

Vamos ver um exemplo de estrutura mínima para um módulo de VPC na AWS:

```hcl
# main.tf
resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

# variables.tf
variable "name" {
  description = "Nome da VPC"
  type        = string
}

variable "cidr_block" {
  description = "Bloco CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "Habilitar nomes DNS na VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Habilitar suporte DNS na VPC"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags para aplicar aos recursos"
  type        = map(string)
  default     = {}
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
```

Este exemplo seguiria a convenção de nomenclatura `terraform-aws-vpc` e poderia ser usado por outros através do Registry como:

```hcl
module "vpc" {
  source = "username/vpc/aws"
  version = "1.0.0"
  
  name       = "minha-vpc"
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Environment = "production"
    Project     = "meu-projeto"
  }
}
```



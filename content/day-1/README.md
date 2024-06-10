# Conhecendo o Terraform

## O que é o Terraform?

Terraform é uma ferramenta de código aberto para provisionamento de infraestrutura como código (IaC). Ele permite que você defina e gerencie a infraestrutura de nuvem em um formato legível por humanos e máquinas, usando uma linguagem de configuração chamada HCL (HashiCorp Configuration Language).

## O que é HCL?

HCL é a linguagem de configuração usada pelo Terraform. É uma linguagem declarativa, o que significa que você descreve o estado desejado da sua infraestrutura, e o Terraform se encarrega de chegar a esse estado. A HCL usa uma sintaxe simples e legível, com blocos, argumentos e identificadores.

## O que é o Statefile?

O statefile é um arquivo JSON que armazena o estado atual da infraestrutura gerenciada pelo Terraform. Ele mapeia os recursos do Terraform para os recursos reais na nuvem. O statefile é crucial para que o Terraform possa determinar as alterações necessárias para alcançar o estado desejado.

## Infraestrutura Mutável vs. Imutável

- **Infraestrutura Mutável:** É a abordagem tradicional, onde os servidores e recursos são atualizados no local. Isso pode levar a inconsistências e dificuldades de gerenciamento à medida que a infraestrutura cresce.
- **Infraestrutura Imutável:** É uma abordagem moderna, onde os servidores e recursos são substituídos por novos quando necessário. Isso garante consistência e facilita o gerenciamento, pois cada recurso tem um estado conhecido e imutável.

## Conceitos Básicos de Cloud

### Providers, Região e Zona

- **Providers:** São plugins que permitem que o Terraform se integre com diferentes provedores de nuvem, como AWS, Azure e GCP.
- **Região:** É uma localização geográfica onde os recursos da nuvem são provisionados.
- **Zona:** É uma subdivisão dentro de uma região, que oferece isolamento e redundância.

## Bucket para garantir o mesmo estado

Para garantir que a equipe utilize o mesmo estado do Terraform, é essencial usar um bucket centralizado (como o S3 da AWS) para armazenar o statefile. Isso garante que todos os membros da equipe estejam trabalhando com a mesma versão do estado da infraestrutura.

## Criando um usuário IAM na AWS

Para iniciar o uso do Terraform na AWS, você precisa criar um usuário IAM com permissões suficientes para gerenciar os recursos da AWS. Para isso você pode usar o console da AWS ou a CLI.

Para criar um usuário IAM utilizando a CLI, você pode usar o seguinte comando:

Exemplo:

```bash
aws iam create-user --user-name meu-usuario
aws iam attach-user-policy --user-name meu-usuario --policy-arn arn:aws:iam::aws
/AdministratorAccess
aws iam create-access-key --user-name meu-usuario
```

Este comando irá criar um usuário IAM chamado `meu-usuario`, anexar a política `AdministratorAccess` a ele e criar uma chave de acesso para ele. Guarde a chave de acesso e a chave secreta em um local seguro, pois elas serão usadas para autenticar o Terraform na AWS.

Esse caso de uso é para usuários que já possuem um usuario e desejam criar um novo usuario para o Terraform, caso você não tenha um usuario, utilize a opção de criar um usuario no console da AWS.

## Criando um bucket S3 com acesso público bloqueado

Para criar um bucket S3 com acesso público bloqueado, você pode usar a CLI da AWS ou o console da AWS.

Exemplo (Console):

1. **Acessar o S3:**

   - Faça login na sua conta da AWS.
   - No menu de serviços, procure por "S3" e selecione-o.

2. **Criar um Bucket:**

   - Clique no botão "Criar bucket".
   - Forneça um nome único para o seu bucket. Esse nome é global, ou seja, não pode ser repetido.

   - Selecione a região onde deseja armazenar o bucket.

3. **Bloquear Acesso Público:**

   - Na seção "Bloquear acesso público", ative todas as opções. Isso garante que o acesso público ao bucket seja bloqueado por padrão.
   - Clique em "Criar bucket".

4. **Verificar as Configurações:**

   - Na lista de buckets, clique no nome do bucket que você acabou de criar.
   - Vá para a aba "Permissões".
   - Na seção "Bloquear acesso público", verifique se todas as opções estão ativadas.

**Observações:**

- Bloquear o acesso público é uma prática de segurança importante para proteger seus dados.
- Você pode conceder acesso a usuários ou serviços específicos por meio de políticas de bucket, ACLs (listas de controle de acesso) e funções do IAM.
- Se você precisar de acesso público para algum conteúdo específico, é possível criar uma política de bucket que permita acesso a objetos específicos.

Exemplo (CLI):

```bash
aws s3api create-bucket --bucket meu-bucket --region us-west-2 --create-bucket-configuration LocationConstraint=us-west-2 --acl private
```

# Entendendo o Terraform

## HCL (HashiCorp Configuration Language)

HCL é a linguagem de configuração usada pelo Terraform para definir a infraestrutura como código.

## Argumentos

São valores passados para um recurso ou módulo. No exemplo `image_id = "abc123"`, "image_id" é o argumento e "abc123" é o valor.

## Blocos

São contêineres para outros conteúdos, como argumentos ou outros blocos aninhados. O exemplo mostra um bloco `network_interface` dentro do recurso `aws_instance`.

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = "eni-123456"
    device_index         = 0
  }
}
```

## Identificadores

São nomes usados para referenciar recursos, variáveis, etc. Eles devem seguir regras específicas de codificação e terminação de linha.

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

## Instalação

Para instalar o Terraform, consulte a [documentação oficial](https://developer.hashicorp.com/terraform/install).

## Comandos Básicos

- `terraform init --upgrade`: Inicializa o diretório de trabalho e baixa os plugins necessários. `--upgrade` garante que os plugins estejam atualizados.
- `terraform plan`: Mostra um plano de execução, listando as ações que o Terraform irá realizar.
- `terraform apply`: Executa o plano de execução, criando ou modificando a infraestrutura.
- `terraform destroy`: Destrói a infraestrutura criada pelo Terraform.

## Autenticação

### Usando o Provider

O bloco `provider "aws"` define as credenciais de acesso e a região da AWS.

```hcl
provider "aws" {
  region     = "us-west-2"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}
```

Por questões de segurança, é recomendável não armazenar as credenciais diretamente no código. Em vez disso, você pode usar variáveis de ambiente, arquivos de configuração ou serviços de autenticação.

### Usando Variáveis de Ambiente

É possível definir as variáveis `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` e `AWS_REGION` no ambiente para autenticar o Terraform.

```bash
export AWS_ACCESS_KEY_ID="my-access-key"
export AWS_SECRET_ACCESS="my-secret-key"
export AWS_REGION="us-west-2"
```

Depois de exportar suas variáveis de ambiente, o Terraform usará essas credenciais para se autenticar na AWS. Lembre-se de proteger suas credenciais e não compartilhá-las publicamente.

## Backend remoto

O backend remoto permite armazenar o statefile em um local centralizado, como um bucket S3. Isso facilita o trabalho em equipe e garante a consistência do estado da infraestrutura.

Exemplo de configuração de backend remoto:

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "terraform.tfstate"
    region = "us-west-2"
  }
```

Adicione essa configuração ao seu arquivo `.tf` para usar um backend remoto.

Caso o terraform já tenha sido inicializado com um backend local, você pode migrar para um backend remoto, normalmente ao utilizar o `terraform init` ele irá perguntar se deseja levar para o seu backend o estado local, caso não pergunte, você pode forçar a migração com o comando `terraform init -reconfigure`. Em caso de erro use o comando `terraform init -migrate-state`.

# O que são os providers no Terraform?

Os providers são plugins que permitem que o Terraform interaja com diferentes provedores de nuvem, como AWS, Azure, GCP, etc. Cada provedor tem seu próprio plugin, que fornece os recursos e a lógica necessária para gerenciar a infraestrutura na nuvem.

Para usar um provedor no Terraform, você precisa configurar as credenciais de acesso e a região do provedor. Isso permite que o Terraform se autentique e provisione recursos na nuvem.

Exemplo de configuração de um provedor AWS:

```hcl
provider "aws" {
  region     = "us-west-2"
  access_key = "my-access
  secret_key
  = "my-secret key"
}
```

Neste exemplo, o bloco `provider "aws"` configura o provedor AWS com a região `us-west-2` e as credenciais de acesso fornecidas. Isso permite que o Terraform provisione recursos na AWS.

Outra forma de autenticar o Terraform é utilizando variáveis de ambiente, como `AWS_ACCESS_KEY_ID` e `AWS_SECRET_ACCESS_KEY`. Isso evita a exposição de credenciais no código e facilita a gestão de segurança.

```bash
export AWS_ACCESS_KEY_ID="my-access-key"
export AWS_SECRET_ACCESS_KEY="my-secret-key"
export AWS_REGION="us-west-2"
```

## Utilizando o alias para múltiplos providers

Com essa opção, é possível utilizar múltiplos providers de um mesmo tipo, por exemplo, dois providers AWS, um para cada região. Para isso, é necessário utilizar o alias para diferenciar os providers.

```hcl
terraform {
  backend "s3" {
    bucket = "descomplicando-terraform-turma-2024"
    key    = "aula_backend"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
```

# O que é e como usar variáveis no Terraform?

É a possibilidade de definir valores dinâmicos para os recursos, evitando a repetição de código e facilitando a manutenção. Além disso, as informações que precisam ser alteradas com frequência nao ficam fixas no código - o chamado hardcode -.

Podemos modificar o comportamento do código de acordo com o ambiente, como por exemplo, alterar o nome de uma instância EC2 de acordo com as variáveis de ambiente, de distintas maneiras.

### Declarando variáveis

É possível declarar variáveis no arquivo `variables.tf` ou diretamente no arquivo `.tf` que está sendo utilizado no bloco chamado `variable`.

```hcl
variable "instance_name" {
  description = "O nome da instância EC2"
  type        = string
  default     = "my-instance"
}
```

As principais formas de declarar variáveis são:

- **Linha de comando:** Usando a flag `-var` para passar valores diretamente na linha de comando.

```bash
terraform plan -out plano -var="instance_name=my-instance"
```

- **Arquivo de variáveis:** Criando um arquivo de variáveis separado e passando-o para o Terraform no bloco `variables`.
  
```hcl
variable "instance_name" {
  type = string
  description = "O nome da instância EC2"
}
```

No arquivo de variáveis voce pode definir um valor como sensivel, para isso basta adicionar o atributo `sensitive = true` na declaração da variável.

- **Variáveis de ambiente:** Usando variáveis de ambiente para definir valores.

```bash
export TF_VAR_instance_name=my-instance
```

- Utilizando o arquivo **`terraform.tfvars`** para definir as variáveis. O arquivo pode ter o seguinte conteúdo:

```hcl
instance_name = "my-instance"
```

Para utilizar o arquivo de **`terraform.tfvars`**:

```bash
terraform plan -out plano -var-file="testing.tfvars"
```

Outra forma de utilizar o `.tfvars` é através do `auto.tfvars`, assim:

```bash
terraform plan -out plano
```

O terraform irá buscar automaticamente o arquivo `auto.tfvars` ou `terraform.tfvars` para carregar as variáveis.

Caso você os distintos arquivos de declaração de variáveis, o Terraform irá seguir a seguinte ordem de importância para carregar as variáveis:

0. Variáveis de ambiente.
1. Utilizando -var e -var-file na linha de comando.
2. Utilizando os arquivos que terminam com `.auto.tfvars`.
3. Utilizando os arquivos que terminam com `.tfvars`.

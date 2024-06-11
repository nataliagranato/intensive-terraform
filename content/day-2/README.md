# O state file do Terraform

O Terraform cria um arquivo chamado `terraform.tfstate` que armazena o estado atual da infraestrutura gerenciada por ele. Esse arquivo é importante para que o Terraform saiba o que já foi criado e o que precisa ser atualizado ou removido. Ele mapeia todos os recursos criados e suas configurações.

Quando você executa o comando `terraform apply`, o Terraform cria ou atualiza a infraestrutura e atualiza o arquivo `terraform.tfstate` com as informações dos recursos criados. Se você remover esse arquivo, o Terraform não saberá o que já foi criado e tentará criar tudo novamente.

Por isso, é importante não remover o arquivo `terraform.tfstate` manualmente. Se você quiser começar do zero, é recomendado usar o comando `terraform destroy` para remover todos os recursos criados e, em seguida, remover o arquivo `terraform.tfstate`.

Além disso, o arquivo `terraform.tfstate` contém informações sensíveis, como senhas e chaves de acesso, que não devem ser expostas. Por isso, é importante proteger esse arquivo e não compartilhá-lo publicamente.

Por padrão, o arquivo `terraform.tfstate` é armazenado localmente no diretório onde você está executando o Terraform. No entanto, é possível configurar o Terraform para armazenar o estado em um local remoto, como um bucket do S3 ou um serviço de armazenamento de estado.

## Backend remoto

Para configurar o armazenamento remoto do estado, você pode usar o bloco `backend` no arquivo de configuração do Terraform. Por exemplo, para armazenar o estado no S3, você pode adicionar o seguinte bloco ao seu arquivo de configuração:

```hcl
// This Terraform configuration sets up the backend configuration for storing the state file in an S3 bucket.

terraform {
    backend "s3" {
        bucket = "terraform2024-granato"
        key    = "state" 
        region = "us-east-1"
    }
}
```

Isso fará com que o Terraform armazene o estado no bucket do S3 especificado. Dessa forma, o estado estará seguro e acessível a partir de qualquer lugar.

Lembre-se de que é importante proteger o acesso ao bucket do S3 para garantir a segurança das informações contidas no estado. Você pode configurar as permissões de acesso ao bucket para restringir quem pode ler e gravar o estado.

# Usando o DynamoDB para bloqueio de estado

O uso do DynamoDB para bloqueio de estado é uma prática recomendada ao usar o Terraform com um backend remoto. O DynamoDB é um serviço de banco de dados NoSQL totalmente gerenciado que fornece bloqueio de estado para garantir que apenas um usuário ou processo possa modificar o estado do Terraform por vez.

Para configurar o bloqueio de estado com o DynamoDB, você pode adicionar o seguinte bloco ao seu arquivo de configuração do Terraform:

```hcl
// This Terraform configuration sets up the DynamoDB table for state locking.
terraform {
  backend "s3" {
    bucket         = "descomplicando-terraform-turma-2024"
    key            = "aula_backend"
    region         = "us-east-1"
    dynamodb_table = "descomplicando-terraform-turma-2024"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

Com o bloco acima, o Terraform usará o DynamoDB para bloquear o estado do Terraform, garantindo que apenas um usuário ou processo possa modificar o estado por vez. Isso evita conflitos e garante a consistência do estado.

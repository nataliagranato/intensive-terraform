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
    bucket         = "terraform2024-granato"
    key            = "aula_backend"
    region         = "us-east-1"
    dynamodb_table = "terraform2024-granato"
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

# Utilizando workspaces no Terraform

Os workspaces no Terraform são uma maneira de organizar e gerenciar diferentes ambientes de infraestrutura dentro de um mesmo diretório de configuração. Cada workspace tem seu próprio estado e pode ser usado para gerenciar ambientes de desenvolvimento, teste, produção, entre outros.

Para criar um novo workspace, você pode usar o comando `terraform workspace new <nome>`. Por exemplo, para criar um workspace chamado `dev`, você pode executar o seguinte comando:

```bash
terraform workspace new dev
```

Depois de criar um workspace, você pode alternar entre os workspaces usando o comando `terraform workspace select <nome>`. Por exemplo, para alternar para o workspace `dev`, você pode executar o seguinte comando:

```bash
terraform workspace select dev
```

É importante ter atenção ao usar workspaces, pois eles compartilham o mesmo diretório de configuração e podem causar conflitos se não forem usados corretamente. Certifique-se de que cada workspace tenha suas próprias configurações e variáveis para evitar conflitos entre os ambientes.

Se você está criando recursos em uma mesma região, mas utilizando workspaces, atente-se ao nome dos recursos, pois o Terraform não permite a criação de recursos com o mesmo nome em workspaces diferentes.

## Import de recursos existentes

O Terraform permite importar recursos existentes em um estado gerenciado por ele. Isso é útil quando você deseja gerenciar recursos que foram criados fora do Terraform ou que foram criados manualmente.

Para importar um recurso existente, você pode usar o comando `terraform import <tipo>.<nome> <id>`. Por exemplo, para importar uma instância EC2 existente, você pode executar o seguinte comando:

```bash
terraform import aws_instance.web i-1234567890abcdef0
```

Isso importará a instância EC2 com o ID `i-1234567890abcdef0` para o estado do Terraform, permitindo que você gerencie esse recurso com o Terraform.

Para gerenciar recursos importados, você precisará adicionar a definição do recurso ao seu arquivo de configuração do Terraform. Certifique-se de que a definição corresponda ao recurso importado para evitar conflitos.

Lembre-se de que o Terraform não importa automaticamente os recursos existentes em um estado gerenciado por ele. Você precisará importar manualmente cada recurso que deseja gerenciar com o Terraform.

Existem algumas limitações ao importar recursos existentes, como a impossibilidade de importar recursos que foram criados com módulos do Terraform ou recursos que dependem de outros recursos que não foram importados. Certifique-se de verificar a documentação do Terraform para obter mais informações sobre as limitações de importação de recursos existentes.

## Um exercicio para fixação

1. Execute o comando terraform import aws_instance.web id_da_instancia para importar uma instância EC2 existente para o estado do Terraform. O terraform irá reclamar que o recurso não existe na configuração, altere seu arquivo `import.tf` para a sugestão do terraform e execute o comando novamente.

```bash
Error: resource address "aws_instance.web" does not exist in the configuration.

Before importing this resource, please create its configuration in the root module. For example:

resource "aws_instance" "web" {
  # (resource arguments)
}
```

```bash
terraform import aws_instance.web i-03101d13a03d63f08
```

A saída do comando será algo parecido com:

```bash
aws_instance.web: Importing from ID "i-03101d13a03d63f08"...
aws_instance.web: Import prepared!
  Prepared aws_instance for import
aws_instance.web: Refreshing state... [id=i-03101d13a03d63f08]

Import successful!

The resources that were imported are shown above. These resources are now in
your Terraform state and will henceforth be managed by Terraform.
```

2. Execute o comando terraform state pull para visualizar o estado atual do Terraform e verificar se a instância EC2 foi importada corretamente.

```bash
terraform state pull > state.tfstate
```

Agora a instância EC2 foi importada para o estado do Terraform e você pode gerenciá-la com o Terraform.

3. Adicione a definição do recurso aws_instance ao seu arquivo de configuração do Terraform para gerenciar a instância importada. Certifique-se de que a definição corresponda ao recurso importado para evitar conflitos.

```hcl
resource "aws_instance" "web" {
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
}
```

O terraform exige que você especifique o tipo de instância e a AMI, então você pode adicionar essas informações ao arquivo `import.tf`. Você pode verificar o seu arquivo de estado para obter essas informações.

4. Execute o comando terraform plan para verificar as alterações propostas pelo Terraform.

```bash
terraform plan
```

A saída do comando será algo parecido com:

```bash
Terraform will perform the following actions:

  # aws_instance.web will be updated in-place
  ~ resource "aws_instance" "web" {
        id                                   = "i-03101d13a03d63f08"
      ~ tags                                 = {
          - "Name" = "granato" -> null
        }
      ~ tags_all                             = {
          - "Name" = "granato" -> null
        }
      + user_data_replace_on_change          = false
        # (37 unchanged attributes hidden)

        # (8 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

O plano está indicando que a tag "Name" será modificada. Se você deseja manter a tag, você pode adicionar a tag ao seu arquivo `import.tf`, verificando no arquivo de estado a tag atual. Execute o `terraform plan` novamente para verificar se a tag será mantida.

A saída do comando será algo parecido com:

```bash
aws_instance.web: Refreshing state... [id=i-03101d13a03d63f08]

No changes. Your infrastructure matches the configuration.

Terraform has compared your real infrastructure against your configuration and found no differences, so no
changes are needed.
```

Agora a instância EC2 foi importada e está sendo gerenciada pelo Terraform. Você pode continuar a gerenciar a instância EC2 com o Terraform, aplicando alterações e mantendo o estado atualizado.

# Uso avancado do import no Terraform

Agora existe um novo bloco de configuração chamado `import` que permite importar recursos existentes diretamente para o estado do Terraform. Isso facilita a importação de recursos existentes e evita a necessidade de usar o comando `terraform import`.

Para usar o bloco `import`, você pode adicionar a seguinte configuração ao seu arquivo de configuração do Terraform:

```hcl
import {
  to = aws_instance.web
  id = "i-03101d13a03d63f08"
}

resource "aws_instance" "web" {
  ami           = "ami-04b70fa74e45c3917"
  instance_type = "t2.micro"
  tags = {
    Name = "granato"
  }
```

Para utilizarmos o `import` dessa forma, precisamos remover o estado atual. Liste o estado atual com o comando `terraform state list` e remova o estado da instância EC2 com o comando `terraform state rm aws_instance.web`.

```bash
terraform state rm aws_instance.web
```

Agora essa instância não está mais no estado do Terraform e podemos adicionar o bloco `import` ao nosso arquivo `import.tf` e executar o comando `terraform plan` para verificar as alterações propostas pelo Terraform.

```bash
terraform plan
```

Agora no seu output você o recurso chamado `aws_instance.web` com o status `import` e o Terraform irá importar a instância EC2 para o estado.

```bash
Plan: 1 to import, 0 to add, 0 to change, 0 to destroy.
```

Execute o comando `terraform apply` para aplicar as alterações e importar a instância EC2 para o estado do Terraform.

```bash
terraform apply -auto-approve
```

A saída do comando será algo parecido com:

```bash
Plan: 1 to import, 0 to add, 0 to change, 0 to destroy.
aws_instance.web: Importing... [id=i-03101d13a03d63f08]
aws_instance.web: Import complete [id=i-03101d13a03d63f08]

Apply complete! Resources: 1 imported, 0 added, 0 changed, 0 destroyed.
```

Agora vamos ver uma forma experimental, o generation configuration.

Antes de iniciarmos remova o estado atual da instância EC2 com o comando `terraform state rm aws_instance.web`.

# Usando o gerador de configuração no Terraform

Para gerar a configuração do Terraform para um recurso existente, você pode usar o comando `terraform generate`. Isso irá gerar a configuração do Terraform para o recurso existente com base nas informações disponíveis.

O seu arquivo de configuração do Terraform deve conter a definição do recurso que você deseja gerar a configuração.

```hcl
import {
  to = aws_instance.web
  id = "i-03101d13a03d63f08"
}
```

Execute o plano para verificar as alterações propostas pelo Terraform.

```bash
terraform plan
```

Ele irá mostrar que o seu target não existe e irá sugerir a criação do recurso.

```bash
terraform plan -generate-config-out=generated.tf
```

Ele irá gerar um arquivo chamado `generated.tf` com a configuração do recurso existente. É recomendado fazer um review do arquivo gerado para garantir que a configuração está correta.

Use com cuidado, pois o gerador de configuração é uma funcionalidade experimental e pode não funcionar corretamente em todos os casos. Veja o output:

```bash
Planning failed. Terraform encountered an error while generating this plan.

╷
│ Warning: Config generation is experimental
│
│ Generating configuration during import is currently experimental, and the generated configuration format
│ may change in future versions.
╵
╷
│ Error: Conflicting configuration arguments
│
│   with aws_instance.web,
│   on generated.tf line 14:
│   (source code not available)
│
│ "ipv6_address_count": conflicts with ipv6_addresses
```

Agora execute o plano e apply novamente e veja a mágica acontecer.

# Utilizando outputs e outputs de um remote state

Os outputs no Terraform são uma maneira de expor informações sobre os recursos criados para serem usadas por outros recursos ou para serem exibidas ao usuário. Eles são úteis para fornecer informações sobre o estado da infraestrutura e para compartilhar dados entre módulos.

Para definir um output no Terraform, você pode adicionar o bloco `output` ao seu arquivo de configuração. Por exemplo, para expor o ID de uma instância EC2, você pode adicionar o seguinte bloco ao seu arquivo de configuração:

```hcl
output "instance_id" {
  value = aws_instance.web.id
}
```

Você verá o output no final do comando `terraform apply`:

```bash
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

instance_ip_addr = "172.31.34.92"
```

# Obtendo outputs de um remote state e utilizando no seu código Terraform

Para obter os outputs de um estado remoto no Terraform, você pode usar o bloco `data` com o tipo `terraform_remote_state`. Isso permite que você acesse os outputs de um estado remoto e os utilize em seu código Terraform.

Para obter os outputs de um estado remoto, você pode adicionar o seguinte bloco ao seu arquivo de configuração:

```hcl
data "terraform_remote_state" "remote" {
  backend = "s3"
  config = {
    bucket = "terraform2024-granato"
    key    = "state"
    region = "us-east-1"
  }
}
```

Com esse bloco, você pode acessar os outputs do estado remoto usando a sintaxe `data.terraform_remote_state.remote.outputs.<nome_do_output>`. Por exemplo, para acessar o output `instance_id` do estado remoto, você pode usar a seguinte sintaxe:

```hcl
output "remote_instance_id" {
  value = data.terraform_remote_state.remote.outputs.instance_id
}
```

Dessa forma, você pode acessar os outputs de um estado remoto e utilizá-los em seu código Terraform. Isso é útil para compartilhar informações entre diferentes configurações do Terraform e para reutilizar dados em vários módulos.

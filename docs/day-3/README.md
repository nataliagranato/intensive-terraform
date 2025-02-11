# Usando modúlos no Terraform

Utilizar modúlos no Terraform é uma prática recomendada para organizar e reutilizar código. Modúlos são um conjunto de recursos que são encapsulados em um diretório e podem ser reutilizados em diferentes partes do código.

## Estrutura de um módulo

A estrutura de um módulo é bem simples, ele é composto por um diretório com os arquivos `.tf` que definem os recursos que serão criados. A estrutura de um módulo pode ser a seguinte:

```
module
│  main.tf
│  variables.tf
│  outputs.tf
```

- `main.tf`: Arquivo que contém a definição dos recursos que serão criados.

- `variables.tf`: Arquivo que contém a definição das variáveis que serão utilizadas no módulo.

- `outputs.tf`: Arquivo que contém a definição das saídas que serão retornadas pelo módulo.

## Utilizando um módulo

Para utilizar um módulo em um arquivo `.tf` basta utilizar a diretiva `module` e passar o caminho do diretório do módulo. Por exemplo:

```hcl
module "example" {
  source = "./module"
  variable1 = "value1"
  variable2 = "value2"
}
```

Neste exemplo, estamos utilizando o módulo que está no diretório `module` e passando os valores das variáveis `variable1` e `variable2`.

## Organizando módulos

Para organizar os módulos em um projeto Terraform, é recomendado criar um diretório chamado `modules` e dentro dele criar um diretório para cada módulo. Por exemplo:

```
modules
│ module1
│ module2
│ module3
```

Dessa forma, é possível organizar os módulos de forma mais clara e reutilizável. Normalmente os arquivos `.tf` de cada módulo são `provider.tf`, `variables.tf`, `main.tf` e `outputs.tf`.

No módulo raiz do projeto crie um arquivo `main.tf` e utilize a diretiva `module` para chamar os módulos que deseja utilizar.

No módulo raiz você pode chamar mais de um módulo, por exemplo:

```hcl
module "module1" {
  source = "./modules/module1"
  variable1 = "value1"
  variable2 = "value2"
}

module "module2" {
  source = "./modules/module2"
  variable1 = "value1"
  variable2 = "value2"
}
```

Ao usar iniciar o Terraform com o comando `terraform init --upgrade` o Terraform irá baixar as dependências dos módulos e você poderá utilizar os recursos definidos nos módulos. Note que no diretório `.terraform` será criado um diretório chamado `modules` que contém os módulos baixados. Para maiiores informações sobre os módulos utilizados veja o arquivo `modules.json` que é criado no diretório `.terraform/modules`.

## Manipulando informações de módulos na raiz

Para isso é necessário que o seu módulo tenha variáveis. Por exemplo, no módulo `module1` você pode definir uma variável chamada `nome` e no módulo raiz você pode passar o valor para essa variável. Por exemplo:

```hcl
module "module1" {
  source = "./modules/module1"
  nome = "valor"
}
```

Dessa forma, você pode passar valores para as variáveis dos módulos e manipular as informações de acordo com a necessidade do seu projeto.

## Movendo states

Com o `terraform state mv` é possível mover um recurso de um arquivo `.tfstate` para outro. Por exemplo, se você tem um recurso que está em um arquivo `.tfstate` e deseja mover para outro arquivo, você pode fazer isso com o comando `terraform state mv`. Vamos ver como isso funciona na prática.

1. Listando states

```shell
terraform state list
```

2. Visualizando detalhes de um recurso

```shell
terraform state show module.projetoa.data.aws_ami.ubuntu
```

3. Movendo um recurso

```shell
terraform state mv aws_instance.web module.nataliagranato.aws_instance.web
```

Isso é muito útil quando você possui um recursos e deseja movê-lo para um módulo, por exemplo. Mover um recurso para um módulo é uma prática recomendada para O comando selecionado é utilizado no contexto do Terraform, uma ferramenta de infraestrutura como código (IaC) que permite definir, provisionar e gerenciar infraestrutura de TI através de arquivos de configuração. O comando em questão, `terraform state mv`, é usado para mover um item no estado do Terraform de um local para outro. Isso pode ser necessário por vários motivos, como reorganizar recursos, refatorar módulos ou ajustar a estrutura do projeto.

No exemplo específico:

```shell
terraform state mv aws_instance.web module.nataliagranato.aws_instance.web
```

Este comando move o recurso `aws_instance.web`, que representa uma instância da AWS (Amazon Web Services), do escopo principal do projeto Terraform para dentro de um módulo chamado `nataliagranato`. O `aws_instance.web` após `module.nataliagranato.` indica que o recurso de instância AWS agora está sendo gerenciado dentro desse módulo.

Mover um recurso para um módulo pode ser útil para melhor organizar os recursos, facilitar a reutilização de configurações em diferentes ambientes ou projetos, e melhorar a manutenção do código. É importante notar que esse comando altera apenas o estado do Terraform, sem afetar a infraestrutura real.

É importante salientar que após mover um recurso no estado do Terraform para um modúlo, é necessário ajustar o código do projeto para refletir essa mudança. Isso pode envolver a atualização de referências ao recurso movido, a definição de variáveis de entrada e saída no módulo, e a garantia de que o código do módulo esteja corretamente integrado ao restante do projeto.

Execute `terraform plan` para verificar as mudanças propostas antes de aplicá-las com `terraform apply`, garantindo que a alteração no estado esteja alinhada com a infraestrutura real.

## Alguns recursos para melhorar o seu módulo

- [Documentação oficial do Terraform sobre módulos](https://developer.hashicorp.com/terraform/tutorials/modules/module)
- [Construindo módulos Terraform](https://developer.hashicorp.com/terraform/tutorials/modules/module-create)
- [Exemplo de módulo no GitHub](https://github.com/terraform-aws-modules/terraform-aws-eks)

## Functions, locals e count

O funcionamento de funções, locals e count em módulos é o mesmo que em arquivos `.tf` comuns. Você pode utilizar funções, locals e count em módulos para manipular informações e recursos de acordo com a necessidade do seu projeto.

- [Funções no Terraform](https://www.terraform.io/docs/language/functions/index.html)

- [Locals no Terraform](https://www.terraform.io/docs/language/values/locals.html)

- [Count no Terraform](https://www.terraform.io/docs/language/meta-arguments/count.html)

O `hcl` possui diversas funções embutidas que podem ser utilizadas para manipular informações ou transformar dados. Por exemplo, a função `format` pode ser utilizada para formatar uma string de acordo com um padrão específico. Veja um exemplo:

```hcl
locals {
  formatted_string = format("Hello, %s!", var.name)
}
```

Neste exemplo, a função `format` é utilizada para criar uma string formatada que inclui o valor da variável `name`. O resultado será uma string no formato `Hello, <valor da variável name>!`.

Além da função `format`, o `hcl` possui diversas outras funções embutidas que podem ser utilizadas para manipular strings, números, listas, mapas e outros tipos de dados. Consulte a documentação oficial do Terraform para obter mais informações sobre as funções disponíveis e como utilizá-las.

Vamos a outro exemplo:

```hcl
locals {
  cidr_block_subnets = cidrsubnets(aws_vpc.main.cidr_block, 8, 8)
}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
}

resource "aws_subnet" "main" {
  count = 2
  vpc_id     = aws_vpc.main.id
  cidr_block = local.cidr_block_subnets[count.index]

  tags = {
    Name = "Main"
  }
}
```

1. **Bloco `locals`:** Este bloco define uma variável local chamada `cidr_block_subnets`. A função `cidrsubnets` é utilizada para gerar uma lista de blocos CIDR para as sub-redes a partir do bloco CIDR da VPC. Os argumentos `8, 8` indicam o tamanho dos novos blocos CIDR que serão criados para as sub-redes.

2. **Recurso `aws_vpc` chamado `main`:** Este bloco define uma VPC na AWS. O atributo `cidr_block` é configurado para usar o valor da variável `var.cidr_block`, que deve ser fornecido externamente. Esta VPC serve como a base para a rede na qual as sub-redes serão criadas.

3. **Recurso `aws_subnet` chamado `main`:** Este bloco define as sub-redes dentro da VPC criada anteriormente. O atributo `count` é configurado para `2`, o que significa que duas instâncias deste recurso serão criadas. O `vpc_id` é definido para associar as sub-redes à VPC `aws_vpc.main`. O `cidr_block` de cada sub-rede é obtido da lista `local.cidr_block_subnets`, usando `count.index` para acessar os elementos individuais, garantindo que cada sub-rede tenha um bloco CIDR único dentro da VPC. Por fim, as sub-redes são etiquetadas com o nome "Main".

Este código ilustra o uso de variáveis locais, a função `cidrsubnets` para cálculo automático de blocos CIDR, e a criação de múltiplas instâncias de um recurso usando o atributo `count`. A estrutura permite a criação de uma VPC e sub-redes relacionadas de forma dinâmica e reutilizável, facilitando a gestão de redes na AWS com o Terraform.

## Lifecycle e depends_on

São recursos que podem ser utilizados para controlar a ordem de execução dos recursos no Terraform. O `lifecycle` permite definir configurações específicas para o ciclo de vida de um recurso, como a prevenção de destruição acidental ou a configuração de ações personalizadas.

O `lifecycle` é uma configuração específica de um recurso. Por exemplo:

```hcl
resource "aws_instance" "web" {
  # Configurações do recurso

  lifecycle {
    create_before_destroy = true 
    prevent_destroy = true
        ignore_changes = [
      tags,
    ]
}
```

- **Create Before Destroy:** Esta configuração garante que um novo recurso seja criado antes que o recurso antigo seja destruído. Isso é útil para garantir a disponibilidade contínua do recurso durante a atualização ou substituição.

- **Prevent Destroy:** Esta configuração impede a destruição acidental do recurso. Quando ativada, o Terraform exibirá um aviso ao tentar destruir o recurso, solicitando confirmação antes de prosseguir.

- **Ignore Changes:** Esta configuração permite ignorar alterações específicas em um recurso durante a atualização. Isso pode ser útil para evitar a interrupção de serviços ou a perda de dados durante a atualização.

Um ponto de ateção: se o `lifecycle` for definido no módulo filho e não for definido no módulo pai, o módulo pai não terá controle sobre o ciclo de vida do recurso.

O `depends_on` é usado para especificar dependências explícitas entre recursos, garantindo que um recurso seja criado ou modificado apenas após a conclusão de outro recurso.

## Documentação do Terraform

- [Terraform CLI](https://developer.hashicorp.com/terraform/cli)
- [Style Guide](https://developer.hashicorp.com/terraform/language/style)
- [Sintaxe HCL](https://developer.hashicorp.com/terraform/language/syntax)
- [Resources](https://developer.hashicorp.com/terraform/language/resources)
- [Providers](https://developer.hashicorp.com/terraform/language/providers)
- [Variables and Outputs](https://developer.hashicorp.com/terraform/language/values)
- [Modules](https://developer.hashicorp.com/terraform/language/modules)
- [Import](https://developer.hashicorp.com/terraform/language/import)
- [State](https://developer.hashicorp.com/terraform/language/state)
- [Tutorials](https://developer.hashicorp.com/terraform/tutorials)
- [Testing HashiCorp Terraform](https://developer.hashicorp.com/terraform/language/tests)

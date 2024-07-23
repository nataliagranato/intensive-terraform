# O que é um module source?

Um module source é um arquivo que contém um ou mais módulos. Um módulo é um conjunto de funções, classes e variáveis que podem ser importadas e utilizadas em outros arquivos.

## Tipos de module source

É possível importar módulos de diversas fontes, como:

### Local paths

Normalmente são diretórios locais que contém os módulos. Para importar um módulo de um diretório local, basta informar o caminho do diretório no arquivo que deseja importar o módulo.

```hcl
module "module_name" {
  source = "./path/to/module"
}
```

### Terraform Registry

No Terraform Registry é possível encontrar módulos prontos para serem utilizados. Para importar um módulo do Terraform Registry, basta informar o nome do módulo no arquivo que deseja importar o módulo.

```hcl
module "module_name" {
  source = "namespace/module_name/registry"
}
```

### Git repositories

São repositórios Git que contém módulos. Para importar um módulo de um repositório Git, basta informar o URL do repositório no arquivo que deseja importar o módulo.

```hcl
module "module_name" {
  source = "git@github.com:nataliagranato/terraform-aws-ec2-module.git"
}   
```

### HTTP URLs

São URLs que contém módulos. Para importar um módulo de um URL, basta informar o URL no arquivo que deseja importar o módulo.

```hcl
module "module_name" {
  source = "https://example.com/path/to/module"
}
```

### S3 buckets

É possível importar módulos de buckets S3. Para importar um módulo de um bucket S3, basta informar o caminho do bucket no arquivo que deseja importar o módulo.

```hcl
module "module_name" {
  source = "s3::https://s3.amazonaws.com/bucket/path/to/module"
}
```

### Modules in package directories

Por fim é possível importar módulos de diretórios de pacotes. Para importar um módulo de um diretório de pacote, basta informar o caminho do diretório no arquivo que deseja importar o módulo.

```hcl
module "module_name" {
  source = "package::/path/to/module"
}
```

Em ambientes de produção, é recomendado utilizar módulos de fontes confiáveis, como o Terraform Registry, para garantir a segurança e a qualidade dos módulos utilizados.

### Versionamento semântico

Para garantir a compatibilidade entre os módulos, é recomendado utilizar o versionamento semântico. O versionamento semântico é um padrão de versionamento que define como as versões de um software devem ser incrementadas.

O versionamento semântico é composto por três números, separados por pontos, que representam a versão do software. Os números são incrementados da seguinte forma:

- O primeiro número representa a versão principal (major). Deve ser incrementado quando são feitas alterações incompatíveis com versões anteriores.

- O segundo número representa a versão secundária (minor). Deve ser incrementado quando são adicionadas funcionalidades de forma compatível com versões anteriores.

- O terceiro número representa a versão de correção (patch). Deve ser incrementado quando são feitas correções de bugs de forma compatível com versões anteriores.

Ao utilizar o Github como repositório de módulos, é possível utilizar tags para versionar os módulos. As tags devem seguir o padrão `vX.Y.Z`, onde `X`, `Y` e `Z` são os números da versão. Por exemplo, a tag `v0.1.0` representa a versão `0.1.0` do módulo.

```hcl
module "aws-ec2" {
  source      = "git@github.com:nataliagranato/terraform-aws-ec2-module.git?ref=v0.1.0"
  nome        = "ec2-teste1"
  region      = "us-east-1"
  environment = "prd"
}
```

Criando uma release especificando tags, é possível garantir a compatibilidade entre os módulos e evitar problemas de dependências. Além disso, o versionamento semântico facilita a identificação das versões dos módulos e permite que os desenvolvedores saibam exatamente quais versões estão sendo utilizadas em seus projetos, caso você realize alterações em seu módulo, o versionamento garante que os usuários do módulo possam utilizar aquela versão específica, evitando quebras em seus projetos.

Outra forma de versionamento é utilizando o `hash` do commit, porém, essa forma não é recomendada, pois o `hash` do commit pode ser alterado a qualquer momento, o que pode causar problemas de compatibilidade entre os módulos. Um exemplo de utilização do `hash` do commit é:

```hcl
module "aws-ec2" {
  source      = "git@github.com:nataliagranato/terraform-aws-ec2-module.git?ref=119c58f6a98cf71a1e5195a32f72fc400ecff8ef"
  nome        = "ec2-teste2"
  region      = "us-east-2"
  environment = "dev"
}
```

Ao executar o comando `terraform init`, o Terraform irá baixar o módulo especificado no arquivo `main.tf` e armazená-lo no diretório `.terraform`. Caso o módulo já tenha sido baixado anteriormente, o Terraform irá verificar se a versão do módulo é a mesma especificada no arquivo `main.tf`. Se a versão do módulo for diferente, o Terraform irá baixar a versão correta do módulo e substituir a versão antiga.

O output do comando `terraform init` irá exibir a versão do módulo baixado e o caminho do diretório onde o módulo foi armazenado.

```shell
Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.
Initializing modules...
Downloading git::ssh://git@github.com/nataliagranato/terraform-aws-ec2-module.git?ref=v0.1.0 for aws-ec2...
```

Você pode ver diversos desenvolvedores que utilizam `monorepo` para armazenar todos os módulos em um único repositório. Um exemplo de utilização de `monorepo` é:

```hcl
Modules em subdiretórios
module "aws-ec2" {
  source      = "git@github.com:nataliagranato/terraform-aws-ec2-module.git//modules/instances?ref=main"
  nome        = "ec2-teste2"
  region      = "us-east-2"
  environment = "dev"
}
```

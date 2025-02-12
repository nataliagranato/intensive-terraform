# Terraform Intensivo

Este é um guia abrangente sobre Terraform, estruturado em diferentes dias de estudo que cobrem desde conceitos básicos até tópicos avançados. O conteúdo está organizado em:

# Índice

## Conhecendo o Terraform:

*  - [O que é o Terraform?](https://github.com/nataliagranato/DescomplicandoTerraform/tree/main/content/day-1#o-que-%C3%A9-o-terraform)
    - [O que é HCL?](https://github.com/nataliagranato/DescomplicandoTerraform/tree/main/content/day-1#o-que-%C3%A9-hcl)
    - [O que é o Statefile?](https://github.com/nataliagranato/DescomplicandoTerraform/tree/main/content/day-1#o-que-%C3%A9-o-statefile)
    - [Infraestrutura Mutável vs. Imutável](https://github.com/nataliagranato/DescomplicandoTerraform/tree/main/content/day-1#infraestrutura-mut%C3%A1vel-vs-imut%C3%A1vel)

## Conceitos Básicos de Cloud

*  - [Providers, Região e Zona](https://github.com/nataliagranato/DescomplicandoTerraform/tree/main/content/day-1#providers-regi%C3%A3o-e-zona)
    - [Bucket para garantir o mesmo estado](https://github.com/nataliagranato/DescomplicandoTerraform/tree/main/content/day-1#bucket-para-garantir-o-mesmo-estado)
    - [Criando um usuário IAM na AWS](https://github.com/nataliagranato/DescomplicandoTerraform/tree/main/content/day-1#criando-um-usu%C3%A1rio-iam-na-aws)
    - [Criando um bucket S3 com acesso público bloqueado](https://github.com/nataliagranato/DescomplicandoTerraform/tree/main/content/day-1#criando-um-bucket-s3-com-acesso-p%C3%BAblico-bloqueado)

## Entendendo o Terraform

*  - [HCL (HashiCorp Configuration Language)](https://github.com/nataliagranato/DescomplicandoTerraform/tree/main/content/day-1#providers-regi%C3%A3o-e-zona)
    - [Instalando o Terraform](https://github.com/nataliagranato/DescomplicandoTerraform/tree/main/content/day-1#instala%C3%A7%C3%A3o)
    - [Comandos básicos](https://github.com/nataliagranato/DescomplicandoTerraform/tree/main/content/day-1#comandos-b%C3%A1sicos)
    - [Backend remoto](https://github.com/nataliagranato/intensive-terraform/blob/main/content/day-1/README.md#backend-remoto)
    - [O que são os providers no Terraform?](https://github.com/nataliagranato/intensive-terraform/blob/main/content/day-1/README.md#o-que-s%C3%A3o-os-providers-no-terraform)
    - [O que é e como usar variáveis no Terraform?](https://github.com/nataliagranato/intensive-terraform/blob/main/content/day-1/README.md#o-que-%C3%A9-e-como-usar-vari%C3%A1veis-no-terraform)


## Gerenciando estado

* - [O state file do Terraform](https://github.com/nataliagranato/intensive-terraform/blob/main/content/day-2/README.md#o-state-file-do-terraform)
  - [Usando o DynamoDB para bloqueio de estado](https://github.com/nataliagranato/intensive-terraform/blob/main/content/day-2/README.md#usando-o-dynamodb-para-bloqueio-de-estado)
  - [Utilizando workspaces no Terraform](https://github.com/nataliagranato/intensive-terraform/blob/main/content/day-2/README.md#utilizando-workspaces-no-terraform)
  - [Import de recursos existentes](https://github.com/nataliagranato/intensive-terraform/blob/main/content/day-2/README.md#import-de-recursos-existentes)
  - [Uso avancado do import no Terraform](https://github.com/nataliagranato/intensive-terraform/blob/main/content/day-2/README.md#uso-avancado-do-import-no-terraform)
  - [Usando o gerador de configuração no Terraform](https://github.com/nataliagranato/intensive-terraform/blob/main/content/day-2/README.md#usando-o-gerador-de-configura%C3%A7%C3%A3o-no-terraform)
  - [Outputs de um remote state](https://github.com/nataliagranato/intensive-terraform/blob/main/content/day-2/README.md#utilizando-outputs-e-outputs-de-um-remote-state)
  - [Obtendo outputs de um remote state e utilizando no seu código Terraform](https://github.com/nataliagranato/intensive-terraform/blob/main/content/day-2/README.md#obtendo-outputs-de-um-remote-state-e-utilizando-no-seu-c%C3%B3digo-terraform)

## Construindo módulos no Terraform

* - [Usando modúlos no Terraform](https://github.com/nataliagranato/intensive-terraform/blob/main/content/day-3/README.md#usando-mod%C3%BAlos-no-terraform) 
  - [Utilizando um módulo](https://github.com/nataliagranato/intensive-terraform/blob/main/content/day-3/README.md#utilizando-um-m%C3%B3dulo)
  - [Organizando seus módulos](https://github.com/nataliagranato/intensive-terraform/blob/main/content/day-3/README.md#organizando-m%C3%B3dulos)
  - [Manipulando informações de módulos na raiz](https://github.com/nataliagranato/intensive-terraform/blob/main/content/day-3/README.md#manipulando-informa%C3%A7%C3%B5es-de-m%C3%B3dulos-na-raiz)
  - [Movendo states](https://github.com/nataliagranato/intensive-terraform/blob/main/content/day-3/README.md#movendo-states)
  - [Alguns recursos para melhorar o seu módulo](https://github.com/nataliagranato/intensive-terraform/blob/main/content/day-3/README.md#alguns-recursos-para-melhorar-o-seu-m%C3%B3dulo)
  - [Documentação do Terraform](https://github.com/nataliagranato/intensive-terraform/blob/main/content/day-3/README.md#documenta%C3%A7%C3%A3o-do-terraform)
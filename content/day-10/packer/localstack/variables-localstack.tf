# Variáveis para o exemplo LocalStack
# Arquivo: terraform/variables-localstack.tf

variable "aws_region" {
  description = "Região AWS para o LocalStack"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "webapp-packer-demo"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "localstack"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t2.micro"
}

variable "min_instances" {
  description = "Número mínimo de instâncias no ASG"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Número máximo de instâncias no ASG"
  type        = number
  default     = 3
}

variable "desired_instances" {
  description = "Número desejado de instâncias no ASG"
  type        = number
  default     = 2
}

variable "ami_owner" {
  description = "Owner da AMI (para busca)"
  type        = string
  default     = "self"
}

variable "ami_name_filter" {
  description = "Filtro para nome da AMI"
  type        = string
  default     = "webapp-localstack-*"
}

variable "key_pair_name" {
  description = "Nome do key pair (opcional para LocalStack)"
  type        = string
  default     = ""
}
# Configuração do provider adaptada para LocalStack
# Arquivo: terraform/providers-localstack.tf

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider AWS configurado para LocalStack
provider "aws" {
  region = var.aws_region

  # Configurações para LocalStack
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # Endpoints customizados para LocalStack
  endpoints {
    ec2         = "http://localhost:4566"
    elbv2       = "http://localhost:4566"
    autoscaling = "http://localhost:4566"
    cloudwatch  = "http://localhost:4566"
    logs        = "http://localhost:4566"
    iam         = "http://localhost:4566"
    s3          = "http://localhost:4566"
    sts         = "http://localhost:4566"
  }
}

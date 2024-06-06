# Define o backend remoto
terraform {
  backend "s3" {
    bucket = "terraform2024-granato"
    key    = "backend_remoto"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure o provedor AWS
provider "aws" {
  region = "us-east-2"
}

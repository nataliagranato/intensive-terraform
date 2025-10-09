# Data sources adaptados para LocalStack
# Arquivo: terraform/data-localstack.tf

# Para LocalStack, vamos usar uma AMI fixa que simulamos
# Normalmente usaríamos o data source para buscar a AMI criada pelo Packer
locals {
  # AMI ID criada pelo nosso build do Packer
  webapp_ami_id = "ami-webapp-1.0.0"

  # Simular AZs disponíveis no LocalStack
  availability_zones = ["us-east-1a", "us-east-1b"]

  # Informações simuladas da conta
  account_id = "123456789012"
  region     = var.aws_region
}

# Para demonstração LocalStack, usamos AMI ID fixa
# Em um ambiente real, isso buscaria a AMI criada pelo Packer
# data "aws_ami" "webapp_ami" - desabilitado para LocalStack
# Usando diretamente local.webapp_ami_id

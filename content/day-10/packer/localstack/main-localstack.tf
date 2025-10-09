# Configuração principal para demonstração Packer + Terraform no LocalStack
# Arquivo: terraform/main-localstack.tf

# Imprimir informações sobre a AMI que vamos usar
output "ami_info" {
  description = "Informações sobre a AMI criada pelo Packer"
  value = {
    ami_id      = local.webapp_ami_id
    created_by  = "packer"
    build_path  = "/tmp/packer-build/"
    description = "WebApp AMI built with Packer for LocalStack demo"
    software = [
      "Ubuntu 22.04 LTS",
      "Docker Engine",
      "Node.js 20.x",
      "Nginx",
      "WebApp",
      "CloudWatch Agent"
    ]
  }
}

# Output com informações do projeto
output "project_info" {
  description = "Informações do projeto"
  value = {
    project_name = var.project_name
    environment  = var.environment
    region       = var.aws_region

    # Informações da infraestrutura
    launch_template_id = aws_launch_template.webapp.id
    autoscaling_group  = aws_autoscaling_group.webapp.name
    security_group_id  = aws_security_group.webapp_instances.id
    min_instances      = var.min_instances
    max_instances      = var.max_instances
    desired_instances  = var.desired_instances

    # Status
    status = "Infrastructure deployed with Terraform using Packer-built AMI"
  }
}

# Output com próximos passos
output "next_steps" {
  description = "Próximos passos para validar a integração"
  value = {
    step_1 = "Verificar se as instâncias foram criadas: aws --endpoint-url=http://localhost:4566 ec2 describe-instances"
    step_2 = "Verificar o Auto Scaling Group: aws --endpoint-url=http://localhost:4566 autoscaling describe-auto-scaling-groups"
    step_3 = "Verificar Security Groups: aws --endpoint-url=http://localhost:4566 ec2 describe-security-groups"
    step_4 = "Check da integração: As instâncias usam a AMI ami-webapp-1.0.0 criada pelo Packer"
    note   = "Esta é uma demonstração funcional da integração Packer + Terraform no LocalStack"
  }
}

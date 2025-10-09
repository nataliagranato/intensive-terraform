# Versão simplificada do módulo de computação para LocalStack
# Arquivo: terraform/compute-localstack.tf

# Security Group para as instâncias
resource "aws_security_group" "webapp_instances" {
  name_prefix = "${var.project_name}-instances-"
  description = "Security group for webapp instances"

  # HTTP do Load Balancer
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # SSH para debug (apenas LocalStack)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Todo tráfego de saída
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-instances-sg"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# Launch Template
resource "aws_launch_template" "webapp" {
  name_prefix   = "${var.project_name}-"
  description   = "Launch template for webapp instances"
  image_id      = local.webapp_ami_id # Usar AMI criada pelo Packer
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.webapp_instances.id]

  # User data para inicializar a aplicação
  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    app_version = "1.0.0"
    environment = var.environment
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-instance"
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
      AMI-Source  = "packer-build"
    }
  }

  tags = {
    Name        = "${var.project_name}-launch-template"
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# Auto Scaling Group - versão simplificada para LocalStack
resource "aws_autoscaling_group" "webapp" {
  name                      = "${var.project_name}-asg"
  min_size                  = var.min_instances
  max_size                  = var.max_instances
  desired_capacity          = var.desired_instances
  health_check_type         = "EC2" # Simplificado para LocalStack
  health_check_grace_period = 300

  # Para LocalStack, vamos usar uma subnet simples
  availability_zones = local.availability_zones

  launch_template {
    id      = aws_launch_template.webapp.id
    version = "$Latest"
  }

  # Políticas de instância
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = "terraform"
    propagate_at_launch = true
  }
}

# Outputs
output "launch_template_id" {
  description = "ID do Launch Template"
  value       = aws_launch_template.webapp.id
}

output "autoscaling_group_name" {
  description = "Nome do Auto Scaling Group"
  value       = aws_autoscaling_group.webapp.name
}

output "security_group_id" {
  description = "ID do Security Group das instâncias"
  value       = aws_security_group.webapp_instances.id
}

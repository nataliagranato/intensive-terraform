data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  #  count                   = var.environment == "prod" ? 2 : 1
  count                   = var.create_instance == true ? 1 : 0
  ami                     = data.aws_ami.ubuntu.id
  instance_type           = "t3.micro"
  disable_api_termination = true
  metadata_options {
    http_tokens = "required"

  }

  root_block_device {
    encrypted = true

  }

  tags = {
    Name       = var.nome
    Env        = var.environment
    Plataforma = data.aws_ami.ubuntu.platform_details
  }
}

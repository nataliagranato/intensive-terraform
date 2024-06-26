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
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t3.micro"
  key_name             = "nataliagranato"
  iam_instance_profile = "nataliagranato-full-ec2"

  monitoring    = true
  ebs_optimized = true

  metadata_options {
    http_endpoint = "disabled"
    http_tokens   = "optional"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name      = "nataliagranato"
    Env       = "develop"
    Workspace = terraform.workspace
    Plataform = data.aws_ami.ubuntu.platform_details
  }
}
module "aws-ec2" {
  source      = "git@github.com:nataliagranato/terraform-aws-ec2-module.git?ref=v0.1.0"
  nome        = "ec2-teste2"
  environment = "dev"
}

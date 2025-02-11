module "aws_instance" {
  source      = "./instances"
  nome        = "aws_instance"
  environment = "prd"
}

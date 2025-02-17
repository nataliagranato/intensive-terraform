module "aws_instance" {
  source          = "./conditionals"
  nome            = "web"
  environment     = "prd"
  create_instance = true

}

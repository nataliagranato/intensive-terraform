# This module creates an EC2 instance in AWS using the terraform-aws-modules/ec2-instance module.

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                   = each.value["instance_type"]
  instance_type          = "t2.micro"
  monitoring             = false
  vpc_security_group_ids = [sg-04cae3f1ca8b8b072]
  subnet_id              = "subnet-01d625b4cb0db58ba"

  tags = {
    Terraform   = "true"
    Environment = each.value["environment"]
  }
}

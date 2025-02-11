# Module: ec2_instance
# This module creates EC2 instances in AWS.
#
# Arguments:
# - for_each: A set of strings representing the names of the instances to be created.
# - source: The source of the module, in this case, "terraform-aws-modules/ec2-instance/aws".
# - name: The name of the instance.
# - instance_type: The type of EC2 instance to be created.
# - monitoring: Whether to enable detailed monitoring for the instance.
# - vpc_security_group_ids: A list of security group IDs to associate with the instance.
# - subnet_id: The ID of the subnet in which to launch the instance.
# - tags: A map of tags to assign to the instance.
#
# Returns:
# - A set of EC2 instances created in AWS.
module "ec2_instance" {
  for_each = toset(["natalia", "granato", "techpreta"])
  source   = "terraform-aws-modules/ec2-instance/aws"

  name                   = each.key
  instance_type          = "t2.micro"
  monitoring             = true
  vpc_security_group_ids = ["sg-04cae3f1ca8b8b072"]
  subnet_id              = "subnet-01d625b4cb0db58ba"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

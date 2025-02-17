# This variable defines the name of the instance.
variable "instance_name" {
  description = "Name of the instance"
  type        = map(any)
  default = {
    web = {
      instance_type = "t3.micro"
      environment   = "dev"
    },
    bd = {
      instance_type = "t2.micro"
      environment   = "dev"
    }
  }
}

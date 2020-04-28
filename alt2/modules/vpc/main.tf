variable name {}
variable "cidr" {}

locals {
  # calculate the subnets from vpc cidr
  # https://www.terraform.io/docs/configuration/functions/cidrsubnets.html
  subnets = [for cidr_block in cidrsubnets(var.cidr, 16, 4, 4) : cidrsubnets(cidr_block, 4, 4)]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.31.0"
  name    = var.name
  cidr    = var.cidr

  # In reality the module would need more parameters to work.
  # hard-code the ones which are the same to all environments
  # others should be derived from vars. for example VPC subnets shoudl be derived
  # from VPC cidr so that each account/vpc chas similar subnet structure.
  public_subnets  = subnets[0]
  private_subnets = subnets[1]

  enable_nat_gateway = true
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
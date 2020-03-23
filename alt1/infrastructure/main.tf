terraform {
  backend "s3" {
    # Just a the shared backend config here. The rest is in
    key     = "base_infra"
    region  = "eu-west-1"
    encrypt = true
  }
}

variable environment_name {}
variable "vpc_cidr" {}

provider "aws" {
  region = "eu-west-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.31.0"
  name = var.environment_name
  cidr = var.vpc_cidr
  # In reality the module would need more parameters to work.
}

output "vpc_id" {
  value = module.vpc.outputs.vpc_id
}
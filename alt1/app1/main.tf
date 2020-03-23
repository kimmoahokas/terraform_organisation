
terraform {
  backend "s3" {
    # Just a the shared backend config here. The rest is in
    key     = "app1"
    region  = "eu-west-1"
    encrypt = true
  }
}

variable environment_name {}

provider "aws" {
  region = "eu-west-1"
}

data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "dev-terraform"
    # app1 developers don't need write access to the infrastructure
    # these can be moved to environment/*/terraform.tfvars if needed
    aws_profile = "dev_readonly"
    key         = "infra"
    region      = "eu-west-1"
  }
}

# The resource config s below are not valid, just examples.
# These can of course be moved to modules if the app1 config gets complicated
resource "ec2-instance" "app-server" {
  name = var.environment_name
  vpc_id = terraform_remote_state.infra.outputs.vpc_id
}

resource "ec2-role" "app-server-role" {
  name = name = var.environment_name
}

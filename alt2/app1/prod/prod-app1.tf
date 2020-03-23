terraform {
  required_version = "~>0.12.23"
  required_providers {
    aws = "~> 2.53"
  }

  backend "s3" {
    bucket      = "prod-terraform"
    aws_profile = "prod_admin"
    key         = "app1"
    region      = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}

data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "prod-terraform"
    # app1 developers don't need write access to the infrastructure
    aws_profile = "dev_readonly"
    key         = "infra"
    region      = "eu-west-1"
  }
}

module "app1-service" {
  source = "../modules/app1-service"
  name   = "app1-prod"
  # get the VPC ID from dev environment infrastructure terraform config
  vpc = data.terraform_remote_state.infra.outputs.vpc_id
}
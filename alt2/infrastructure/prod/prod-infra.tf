terraform {
  backend "s3" {
    bucket      = "prod-terraform"
    aws_profile = "prod-admin"
    key         = "base_infra"
    region      = "eu-west-1"
  }
}

module "vpc" {
  # "proxy" vpc module that exposes only minimal config possibilities for each
  # environment root module
  source = "../modules/vpc"
  # we can also reference the module by git tag if different environments need
  # different version of the module
  #  git::https://example.com/vpc.git?ref=v1.2.0

  name = "prod"
  cidr = "10.1.0.0/16"
}

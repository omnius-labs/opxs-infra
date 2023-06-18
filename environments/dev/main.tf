terraform {
  cloud {
    organization = "omnius-labs"
    workspaces {
      name = "opxs-infra-dev"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.57.0"
    }
  }
}

provider "aws" {
}

module "opxs" {
  source = "../../module"

  domain_name     = "omnius-labs.com"
  sub_domain_name = "opxs-dev.omnius-labs.com"
  api_domain_name = "api.opxs-dev.omnius-labs.com"

  run_mode = "dev"
  region   = "us-east-1"

  subnet_public_1 = "us-east-1a"
  subnet_public_2 = "us-east-1b"

  postgres_user       = var.postgres_user
  postgres_password   = var.postgres_password
  opxs_api_jwt_secret = var.opxs_api_jwt_secret
}

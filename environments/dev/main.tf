terraform {
  required_version = "~> 1.4.4"
  cloud {
    organization = "omnius-labs"
    workspaces {
      name = "opxs-infra-dev"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.20.0"
    }
  }
}

provider "aws" {
}

module "opxs" {
  source = "../../resources"

  domain_name     = "opxs-dev.omnius-labs.com"
  api_domain_name = "api.opxs-dev.omnius-labs.com"

  run_mode = "dev"
  region   = "us-east-1"

  availability_zone_1 = "us-east-1a"
  availability_zone_2 = "us-east-1b"

  postgres_user             = var.postgres_user
  postgres_password         = var.postgres_password
  jwt_secret_current        = var.jwt_secret_current
  jwt_secret_retired        = var.jwt_secret_retired
  auth_google_client_id     = var.auth_google_client_id
  auth_google_client_secret = var.auth_google_client_secret
}

# resource "aws_lambda_function" "opxs_batch_email_send_lambda" {
#   function_name = "opxs-batch-email-send-lambda"
#   role          = aws_iam_role.lambda_role.arn
# }

variable "opxs_api_postgres_user" {}
variable "opxs_api_postgres_password" {}
variable "opxs_api_jwt_secret" {}

locals {
  opxs_api_secrets = {
    postgres_user     = var.opxs_api_postgres_user
    postgres_password = var.opxs_api_postgres_password
    jwt_secret        = var.opxs_api_jwt_secret
  }
}

resource "aws_secretsmanager_secret" "opxs_api" {
  name = "opxs-api"
}

resource "aws_secretsmanager_secret_version" "opxs_api" {
  secret_id     = aws_secretsmanager_secret.opxs_api.id
  secret_string = jsonencode(local.opxs_api_secrets)
}

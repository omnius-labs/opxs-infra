locals {
  opxs_api_secrets = {
    postgres_user             = var.postgres_user
    postgres_password         = var.postgres_password
    jwt_secret_current        = var.jwt_secret_current
    jwt_secret_retired        = var.jwt_secret_retired
    auth_google_client_id     = var.auth_google_client_id
    auth_google_client_secret = var.auth_google_client_secret
  }
}

resource "aws_secretsmanager_secret" "opxs_api" {
  name = "opxs-api"
}

resource "aws_secretsmanager_secret_version" "opxs_api" {
  secret_id     = aws_secretsmanager_secret.opxs_api.id
  secret_string = jsonencode(local.opxs_api_secrets)
}

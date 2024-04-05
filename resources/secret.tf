locals {
  opxs_api_secrets = {
    postgres_user               = var.postgres_user
    postgres_password           = var.postgres_password
    jwt_secret_current          = var.jwt_secret_current
    jwt_secret_retired          = var.jwt_secret_retired
    auth_google_client_id       = var.auth_google_client_id
    auth_google_client_secret   = var.auth_google_client_secret
    discord_release_webhook_url = var.discord_release_webhook_url
  }
}

resource "aws_secretsmanager_secret" "opxs" {
  name = "opxs"
}

resource "aws_secretsmanager_secret_version" "opxs" {
  secret_id     = aws_secretsmanager_secret.opxs.id
  secret_string = jsonencode(local.opxs_api_secrets)
}

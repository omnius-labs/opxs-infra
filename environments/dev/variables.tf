variable "postgres_user" {
  type = string
}

variable "postgres_password" {
  type = string
}

variable "jwt_secret_current" {
  type = string
}

variable "jwt_secret_retired" {
  type = string
}

variable "auth_google_client_id" {
  type = string
}

variable "auth_google_client_secret" {
  type = string
}

variable "discord_release_webhook_url" {
  type = string
}

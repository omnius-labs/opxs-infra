variable "domain_name" {
  type = string
}

variable "api_domain_name" {
  type = string
}

variable "run_mode" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "availability_zone_1" {
  type = string
}

variable "availability_zone_2" {
  type = string
}

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

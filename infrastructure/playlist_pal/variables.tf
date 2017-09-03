variable "environment" {
  type = "string"
}

variable "frontend_container_version" {
  type = "string"
  default = "latest"
}

variable "backend_container_version" {
  type = "string"
  default = "latest"
}

variable "api_url" {
  type = "string"
  default = "playlist-pal.eddylane.co.uk:4000"
}

variable "aws_availability_zones" {
  default = "eu-west-1a,eu-west-1b"
}

variable "domain" {
  type = "string"
  default = "playlist-pal.eddylane.co.uk"
}

variable "postgres_user" {
  type = "string"
  default = "app_cluster"
}

variable "postgres_db" {
  type = "string"
  default = "playlist_pal"
}

variable "postgres_password" {
  type = "string"
}

variable "postgres_port" {
  type = "string"
  default = "5432"
}

variable "guardian_secret_key" {
  type = "string"
}

variable "secret_key_base" {
  type = "string"
}

variable "aws_region" {
  type = "string"
  default = "eu-west-1"
}
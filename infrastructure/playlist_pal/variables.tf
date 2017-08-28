variable "environment" {
  type = "string"
}

variable "frontend_container_version" {
  type = "string"
  default = "latest"
}

variable "api_url" {
  type = "string"
  default = "api_url_replace_me"
}

variable "aws_availability_zones" {
  default = "eu-west-1a,eu-west-1b"
}

variable "domain" {
  type = "string"
}
provider "aws" {
  region = "${var.aws_region}"
  version = "~> 0.1"
}

terraform {

  backend "s3" {
    encrypt = true
    bucket = "playlist-pal-terraform-state"
    key = "staging/terraform.tfstate"
    region = "eu-west-1"
  }

}

module "main" {

  source = "../../playlist_pal"
  environment = "staging"
  domain = "playlist-pal.eddylane.co.uk"

  secret_key_base = "${var.secret_key_base}"
  guardian_secret_key = "${var.guardian_secret_key}"
  postgres_password = "${var.postgres_password}"

}
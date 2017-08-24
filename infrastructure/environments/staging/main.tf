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
}
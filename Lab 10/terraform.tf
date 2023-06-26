terraform {

  backend "local" {
    path = ""
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-west-2"
  access_key = ""
  secret_key = ""

  default_tags {
    tags = {
      Provisioned = "Terraform"
    }
  }
}

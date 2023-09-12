terraform {
  backend "s3" {
    bucket         = ""
    key            = "terraform.tfstate"
    region         = ""
    dynamodb_table = ""
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.9"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = ""

  default_tags {
    tags = {
      Provisioned = "Terraform"
    }
  }
}

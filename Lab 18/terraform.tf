terraform {
  backend "s3" {
    bucket         = ""
    key            = "terraform.tfstate"
    region         = "us-west-2"
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
  region = "us-west-2"

  default_tags {
    tags = {
      Provisioned = "Terraform"
    }
  }
}

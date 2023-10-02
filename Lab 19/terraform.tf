terraform {
  backend "s3" {
    bucket         = "terraform-charles-uneze-s3"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = ""
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.19"
    }

    null = {
      source = "hashicorp/null"
      version = "3.2.1"
    }
  }
}

# Configure the AWS Provider for Account A
provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Provisioned = "Terraform"
    }
  }
}

# Configure the AWS Provider for Account B
provider "aws" {
  region     = "us-west-2"
  access_key = ""
  secret_key = ""
  alias      = "Account_B"
  default_tags {
    tags = {
      Name = "Account B"
    }
  }
}


terraform {

  backend "local" {
    path = ""
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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

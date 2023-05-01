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
  alias = "Account_1"

  default_tags {
    tags = {
      Name = "Account 1"
    }
  }
}

# Configure the AWS Provider for Account 2
provider "aws" {
  region     = "us-west-2"
  access_key = ""
  secret_key = ""
  alias      = "Account_2"
  default_tags {
    tags = {
      Name = "Account 2"
    }
  }
}

terraform {

  backend "local" {
    path = ""
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.12"
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

provider "aws" {
  alias      = "us-east-1"
  region     = "us-east-1"
  access_key = ""
  secret_key = ""

  default_tags {
    tags = {
      Name = "us-east-1"
    }
  }
}

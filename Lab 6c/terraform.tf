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
  
  default_tags {
    tags = {
      Name = "us-west-2"
    }
  }
}

provider "aws" {
  alias      = "us-east-1"
  region     = "us-east-1"

  default_tags {
    tags = {
      Name = "us-east-1"
    }
  }
}
terraform {
#  backend "remote" {
#    hostname     = "app.terraform.io"
#    organization = ""
#    workspaces {
#      name = "Lab-1"
#    }
#  }

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

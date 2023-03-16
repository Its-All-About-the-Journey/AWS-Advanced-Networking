terraform {

    backend "local" {
      path = "/mnt/c/Users/Admin/Documents//AWS Advanced Networking/Lab 1/terraform.tfstate"
    }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

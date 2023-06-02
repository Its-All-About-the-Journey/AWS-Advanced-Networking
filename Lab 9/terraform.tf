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
  alias      = "west-1"
  region     = "us-west-1"
  access_key = ""
  secret_key = ""

  default_tags {
    tags = {
      Provisioned = "Terraform"
    }
  }
}

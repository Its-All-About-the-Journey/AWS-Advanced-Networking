variable "VPC_A_CIDRs" {
  type = map(string)
  default = {
    "vpc"    = "10.0.0.0/16"
    "subnet" = "10.0.1.0/24"
  }
}

variable "VPC_B_CIDRs" {
  type = map(string)
  default = {
    "vpc"    = "10.1.0.0/16"
    "subnet" = "10.1.1.0/24"
  }
}

variable "VPC_C_CIDRs" {
  type = map(string)
  default = {
    "vpc"    = "10.2.0.0/16"
    "subnet" = "10.2.1.0/24"
  }
}

variable "VPC_D_CIDRs" {
  type = map(string)
  default = {
    "vpc"    = "10.3.0.0/16"
    "subnet" = "10.3.1.0/24"
  }
}

variable "VPC_E_CIDRs" {
  type = map(string)
  default = {
    "vpc"    = "10.4.0.0/16"
    "subnet" = "10.4.1.0/24"
  }
}

variable "VPC_F_CIDRs" {
  type = map(string)
  default = {
    "vpc"    = "10.5.0.0/16"
    "subnet" = "10.5.1.0/24"
  }
}

variable "VPC_G_CIDRs" {
  type = map(string)
  default = {
    "vpc"    = "10.6.0.0/16"
    "subnet" = "10.6.1.0/24"
  }
}

variable "region_1" {
  type    = string
  default = "us-west-1"
}

variable "region_2" {
  type    = string
  default = "us-west-2"
}

variable "availability_zone" {
  type = map(string)
  default = {
    "west-2" = "us-west-2a",
    "west-1" = "us-west-1a"
  }
}

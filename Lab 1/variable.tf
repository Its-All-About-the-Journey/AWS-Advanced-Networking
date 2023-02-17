# IAMADMIN USER CREDENTIALS
variable "access_key" {
  type    = string
  default = ""
}

variable "secret_key" {
  type    = string
  default = ""
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "aws_subnet_attributes" {
  type = string
  default = "10.0.0.0/24"
}

variable "aws_vpc_attributes" {
  type = map(any)
  default = {
    cidr_block = "10.0.0.0/16"
    instance_tenancy   = "default"
}
}

variable “availability_zone” {
  type = string
  default = "eu-west-2a"
}

variable "Internet_IP_for_Route_a_string" {
	type = string
	default = "0.0.0.0/0"
}

variable "Internet_IP_for_SG_a_list" {
	type = list
	default = ["0.0.0.0/0"]
}

variable "aws_instance_AWS_Linux_attributes" {
  type = map(any)
  default = {
    ami               = "ami-08cd358d745620807"
    instance_type     = "t2.micro"
    tenancy = "default"
  }
}

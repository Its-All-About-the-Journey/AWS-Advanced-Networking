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

variable "aws_vpc_Lab_2_VPC" {
  type    = string
  default = "10.0.0.0/16"
}

variable "aws_subnet_Public_A_attributes" {
  type = map(any)
  default = {
    cidr_block        = "10.0.20.0/24"
    availability_zone = "eu-west-2a"
  }
}

variable "Internet_IP_for_Route_a_string" {
  type    = string
  default = "0.0.0.0/0"
}


variable "aws_instance_attributes" {
  type = map(any)
  default = {
    ami               = "ami-08cd358d745620807"
    instance_type     = "t2.micro"
    availability_zone = "eu-west-2a"
    key_name          = ""
    tenancy           = "default"
  }
}

variable "SSH_attributes" {
  type = map(number)
  default = {
    from_port = 22
    to_port   = 22
  }
}

variable "Internet_IP_for_SG_a_list" {
  type    = list(any)
  default = ["0.0.0.0/0"]
}

variable "aws_subnet_Private_A_attributes" {
  type = map(any)
  default = {
    cidr_block        = "10.0.10.0/24"
    availability_zone = "eu-west-2a"
  }
}

variable "HTTP_attributes" {
  type = map(number)
  default = {
    from_port = 80
    to_port   = 80
  }
}

variable "HTTPS_attributes" {
  type = map(number)
  default = {
    from_port = 443
    to_port   = 443
  }
}

variable "Euphemeral_ports_attributes" {
  type = map(number)
  default = {
    from_port = 1024
    to_port   = 65535
  }
}

variable "Linux_ports_attributes" {
  type = map(number)
  default = {
    from_port = 32768
    to_port   = 61000
  }
}

variable "aws_nat_gateway_NAT_GW_attributes" {
  type    = string
  default = "public"
}

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
  type = map(any)
  default = {
    cidr_block        = "10.0.0.0/24"
    availability_zone = "eu-west-2a"
  }
}

variable "aws_vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "Internet_IP_for_Routes" {
	type = string
	default = "0.0.0.0/0"
}

variable "Internet_IP_for_SG" {
	type = list
	default = ["0.0.0.0/0"]
}

variable "Allow_ICMP_Echo_Req" {
  type = map(number)
  default = {
    from_port = 8
    to_port   = 8
  }
}

variable "Allow_SSH" {
  type = map(number)
  default = {
    from_port = 22
    to_port   = 22
  }
}

variable "Allow_Internet" {
  type = map(number)
  default = {
    from_port = 0
    to_port   = 0
  }
}

variable "aws_instance" {
  type = map(any)
  default = {
    ami               = "ami-08cd358d745620807"
    availability_zone = "eu-west-2a"
    instance_type     = "t2.micro"
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "us-west-2"
  access_key = ""
  secret_key = ""
}

resource "aws_vpc" "VPC_A" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC_A"
  }
}

resource "aws_internet_gateway" "VPC_A_IGW" {
  vpc_id = aws_vpc.VPC_A.id

  tags = {
    "name" = "VPC_A_IGW"
  }
}

resource "aws_subnet" "public_subnet_for_VPC_A_AZ_2A" {
  vpc_id                  = aws_vpc.VPC_A.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public_subnet_for_VPC_A_AZ_2A"
  }
}

resource "aws_default_route_table" "Default_VPC_A_RT" {
  default_route_table_id = aws_vpc.VPC_A.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_A_IGW.id
  }

  tags = {
    Name = "Default_VPC_A_RT"
  }
}

resource "aws_default_network_acl" "Default_VPC_A_NACL" {
  default_network_acl_id = aws_vpc.VPC_A.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    "name" = "Default_VPC_A_NACL"
  }
}

resource "aws_default_security_group" "Default_VPC_A_SG" {
  vpc_id = aws_vpc.VPC_A.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "VPC_A_Public_Instance" {
  ami               = "ami-0b029b1931b347543"
  instance_type     = "t2.micro"
  tenancy           = "default"
  availability_zone = "us-west-2a"
  key_name          = "CharlesUneze"
  subnet_id         = aws_subnet.public_subnet_for_VPC_A_AZ_2A.id
  security_groups   = ["${aws_default_security_group.Default_VPC_A_SG.id}"]

  tags = {
    "name" = "VPC_A_Public_Instance"
  }
}

resource "aws_subnet" "private_subnet_for_VPC_A_AZ_2A" {
  vpc_id            = aws_vpc.VPC_A.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "private_subnet_for_VPC_A_AZ_2A"
  }
}

resource "aws_instance" "VPC_A_Private_Instance" {
  ami               = "ami-0b029b1931b347543"
  instance_type     = "t2.micro"
  tenancy           = "default"
  availability_zone = "us-west-2a"
  key_name          = "CharlesUneze"
  subnet_id         = aws_subnet.private_subnet_for_VPC_A_AZ_2A.id
  security_groups   = ["${aws_default_security_group.Default_VPC_A_SG.id}"]

  tags = {
    "name" = "VPC_A_Private_Instance"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = aws_vpc.VPC_A.id
  service_name    = "com.amazonaws.us-west-2.s3"
  route_table_ids = ["${aws_default_route_table.Default_VPC_A_RT.id}"]
}

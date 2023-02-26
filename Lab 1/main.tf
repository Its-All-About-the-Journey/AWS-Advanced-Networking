# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
  #shared_credentials_files = "C:\\Users\\Admin\\.aws\\credentials"
  access_key = var.access_key
  secret_key = var.secret_key
}

# Create VPC
resource "aws_vpc" "VPC_A" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    name = "VPC_A"
  }
}

# Create Subnet
resource "aws_subnet" "VPC_A_Subnet_A" {
  vpc_id                  = aws_vpc.VPC_A.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-west-2a"

  tags = {
    name = "VPC_A_Subnet_A"
  }
}

# Specify the default NACL, regardless if the VPC creates it on default
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

# Specify the default SG, regardless if the VPC creates it on default
resource "aws_default_security_group" "Default_VPC_A_SG" {
  vpc_id = aws_vpc.VPC_A.id

  ingress {
    protocol  = -1
    from_port = 0
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "name" = "Default_VPC_A_SG"
  }
}

# Create the Internet Gateway
resource "aws_internet_gateway" "VPC_A_IGW" {
  vpc_id = aws_vpc.VPC_A.id

  tags = {
    name = "VPC_A_IGW"
  }
}

# Create the default route table
resource "aws_default_route_table" "VPC_A_Default_RT" {
  default_route_table_id = aws_vpc.VPC_A.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_A_IGW.id
  }

  tags = {
    name = "VPC_A_Default_RT"
  }
}

# Create AWS instance
resource "aws_instance" "VPC_A_Subnet_A_AWS_Linux" {
  ami               = "ami-08cd358d745620807"
  instance_type     = "t2.micro"
  tenancy           = "default"
  availability_zone = "eu-west-2a"
  subnet_id = aws_subnet.VPC_A_Subnet_A.id

  tags = {
    name = "VPC_A_Subnet_A_AWS_Linux"
  }
}

# Create an Elastic IP
resource "aws_eip" "VPC_A_EIP" {
  instance = aws_instance.VPC_A_Subnet_A_AWS_Linux.id
  vpc      = true
  tags = {
    name = "VPC_A_EIP"
  }
}

# Associate the Elastic IP to the instance
resource "aws_eip_association" "VPC_A_EIP-Association" {
  instance_id   = aws_instance.VPC_A_Subnet_A_AWS_Linux.id
  allocation_id = aws_eip.VPC_A_EIP.id
}

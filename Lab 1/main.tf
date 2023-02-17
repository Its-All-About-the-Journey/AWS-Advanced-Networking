# Configure the AWS Provider
provider "aws" {
  region = var.region
  #shared_credentials_files = "C:\\Users\\Admin\\.aws\\credentials"
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc" "Lab_1_VPC" {
  cidr_block       = var.aws_vpc_attributes.cidr_block
  instance_tenancy = var.aws_vpc_attributes.instance_tenancy

  tags = {
    name           = "Lab_1_VPC"
  }
}

resource "aws_subnet" "Lab_1_Subnet" {
  vpc_id                  = aws_vpc.Lab_1_VPC.id
  cidr_block              = var.aws_subnet_attributes
  map_public_ip_on_launch = "true"
  availability_zone       = var.availability_zone

  tags = {
    name           = "Lab_1_Subnet"
  }
}

resource "aws_internet_gateway" "Lab_1_IGW" {
  vpc_id = aws_vpc.Lab_1_VPC.id

  tags = {
    name           = "Lab_1_IGW"
  }
}

resource "aws_default_route_table" "Lab_1_RT" {
  default_route_table_id =  aws_vpc.Lab_1_VPC.default_route_table_id

  route {
    cidr_block = var.Internet_IP_for_Route_a_string
    gateway_id = aws_internet_gateway.Lab_1_IGW.id
  }

  tags = {
    name           = "Lab_1_RT"
  }
}

resource "aws_instance" "AWS_Linux" {
  ami                    = var.aws_instance_AWS_Linux_attributes.ami
  instance_type          = var.aws_instance_AWS_Linux_attributes.instance_type
  tenancy                = var.aws_instance_AWS_Linux_attributes.tenancy
  availability_zone      = var.availability_zone

  tags = {
    name           = "Lab_1_AWS_Linux"
  }
}

resource "aws_eip" "Lab_1_EIP" {
  instance = aws_instance.AWS_Linux.id
  vpc      = true
  tags = {
    name           = "Lab_1_EIP"
  }
}

resource "aws_eip_association" "Lab_1_EIP-Association" {
  instance_id   = aws_instance.AWS_Linux.id
  allocation_id = aws_eip.Lab_1_EIP.id
}

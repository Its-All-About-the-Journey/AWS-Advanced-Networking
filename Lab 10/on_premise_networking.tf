resource "aws_vpc" "VPC_B" {
  provider         = aws.us-west-1
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC_B"
  }
}

resource "aws_internet_gateway" "VPC_B_IGW" {
  provider = aws.us-west-1
  vpc_id   = aws_vpc.VPC_B.id

  tags = {
    "name" = "VPC_B_IGW"
  }
}

resource "aws_subnet" "public_subnet_for_VPC_B_AZ_2A" {
  provider          = aws.us-west-1
  vpc_id            = aws_vpc.VPC_B.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-west-1a"

  tags = {
    Name = "public_subnet_for_VPC_B_AZ_2A"
  }
}

resource "aws_route_table" "VPC_B_Public_RT" {
  provider = aws.us-west-1
  vpc_id   = aws_vpc.VPC_B.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_B_IGW.id
  }

  route {
    cidr_block           = "192.168.1.0/24"
    network_interface_id = aws_instance.VPC_B_Customer_Gateway.primary_network_interface_id
  }

  tags = {
    Name = "VPC_B_Public_RT"
  }
}

resource "aws_route_table_association" "VPC_B_Public_RT_association" {
  provider       = aws.us-west-1
  subnet_id      = aws_subnet.public_subnet_for_VPC_B_AZ_2A.id
  route_table_id = aws_route_table.VPC_B_Public_RT.id
}

resource "aws_eip" "CGW_EIP" {
  provider = aws.us-west-1
  vpc      = true
}

resource "aws_eip_association" "CGW_EIP_Assoc" {
  provider      = aws.us-west-1
  allocation_id = aws_eip.CGW_EIP.id
  instance_id   = aws_instance.VPC_B_Customer_Gateway.id
}

resource "aws_vpc" "VPC_A" {
  cidr_block       = "10.0.0.0/16"
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

resource "aws_subnet" "private_subnet_for_VPC_A_AZ_2A" {
  vpc_id            = aws_vpc.VPC_A.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "private_subnet_for_VPC_A_AZ_2A"
  }
}

resource "aws_route_table" "VPC_A_Private_RT" {
  vpc_id = aws_vpc.VPC_A.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.SD-WAN.id
  }

  tags = {
    Name = "VPC_A_Private_RT"
  }
}

resource "aws_route_table_association" "VPC_A_Private_RT_association" {
  subnet_id      = aws_subnet.private_subnet_for_VPC_A_AZ_2A.id
  route_table_id = aws_route_table.VPC_A_Private_RT.id
}

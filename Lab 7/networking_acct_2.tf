resource "aws_vpc" "VPC_A_Acct_2" {
  cidr_block       = "172.20.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  provider         = aws.Account_2

  tags = {
    Name = "VPC_A_Acct_2"
  }
}

resource "aws_internet_gateway" "VPC_A_Acct_2_IGW" {
  vpc_id   = aws_vpc.VPC_A_Acct_2.id
  provider = aws.Account_2

  tags = {
    "name" = "VPC_A_Acct_2_IGW"
  }
}

resource "aws_subnet" "public_subnet_for_VPC_A_AZ_2A_Acct_2" {
  vpc_id            = aws_vpc.VPC_A_Acct_2.id
  cidr_block        = "172.20.1.0/24"
  availability_zone = "us-west-2a"
  provider          = aws.Account_2

  tags = {
    Name = "public_subnet_for_VPC_B_AZ_2A_Acct_2"
  }
}

resource "aws_subnet" "private_subnet_for_VPC_A_AZ_2A_Acct_2" {
  vpc_id            = aws_vpc.VPC_A_Acct_2.id
  cidr_block        = "172.20.2.0/24"
  availability_zone = "us-west-2a"
  provider          = aws.Account_2

  tags = {
    Name = "private_subnet_for_VPC_A_AZ_2A_Acct_2"
  }
}

resource "aws_route_table" "VPC_A_Public_RT_Acct_2" {
  vpc_id   = aws_vpc.VPC_A_Acct_2.id
  provider = aws.Account_2

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_A_Acct_2_IGW.id
  }

  tags = {
    Name = "VPC_A_Public_RT_Acct_2"
  }
}

resource "aws_route_table" "VPC_A_Private_RT_Acct_2" {
  vpc_id   = aws_vpc.VPC_A_Acct_2.id
  provider = aws.Account_2

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.VPC_A_NGW_Acct_2.id
  }

  route {
    cidr_block                = "192.168.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.VPC_A_Acct_1_and_VPC_A_Acct_2_Peering.id
  }

  tags = {
    Name = "VPC_A_Private_RT_Acct_2"
  }
}

resource "aws_route_table_association" "VPC_A_Private_RT_association_Acct_2" {
  subnet_id      = aws_subnet.private_subnet_for_VPC_A_AZ_2A_Acct_2.id
  route_table_id = aws_route_table.VPC_A_Private_RT_Acct_2.id
  provider       = aws.Account_2
}

resource "aws_route_table_association" "VPC_A_Public_RT_association_Acct_2" {
  subnet_id      = aws_subnet.public_subnet_for_VPC_A_AZ_2A_Acct_2.id
  route_table_id = aws_route_table.VPC_A_Public_RT_Acct_2.id
  provider       = aws.Account_2
}

resource "aws_eip" "VPC_A_EIP_Acct_2" {
  vpc      = true
  provider = aws.Account_2
}

resource "aws_nat_gateway" "VPC_A_NGW_Acct_2" {
  allocation_id     = aws_eip.VPC_A_EIP_Acct_2.id
  subnet_id         = aws_subnet.public_subnet_for_VPC_A_AZ_2A_Acct_2.id
  connectivity_type = "public"
  provider          = aws.Account_2
}


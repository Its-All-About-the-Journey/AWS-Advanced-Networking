resource "aws_vpc" "My_VPC" {
  cidr_block           = "192.168.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "My_VPC"
  }
}

resource "aws_internet_gateway" "My_VPC_IGW" {
  vpc_id = aws_vpc.My_VPC.id

  tags = {
    "name" = "My_VPC_IGW"
  }
}

resource "aws_subnet" "public_subnet_for_My_VPC_AZ_2A" {
  vpc_id            = aws_vpc.My_VPC.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "public_subnet_for_My_VPC_AZ_2A"
  }
}

resource "aws_subnet" "public_subnet_for_My_VPC_AZ_2B" {
  vpc_id            = aws_vpc.My_VPC.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "public_subnet_for_My_VPC_AZ_2B"
  }
}

resource "aws_security_group" "My_VPC_SG" {
  name        = "My_VPC_SG"
  description = "Allow SSH, HTTP and ICMP inbound traffic"
  vpc_id      = aws_vpc.My_VPC.id

  ingress {
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP into VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP into VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "My_VPC_SG"
  }
}

resource "aws_route_table" "My_VPC_RT" {
  vpc_id = aws_vpc.My_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.My_VPC_IGW.id
  }

  tags = {
    Name = "My_VPC_RT"
  }
}

resource "aws_route_table_association" "My_VPC_RT_association_AZ_2A" {
  subnet_id      = aws_subnet.public_subnet_for_My_VPC_AZ_2A.id
  route_table_id = aws_route_table.My_VPC_RT.id
}

resource "aws_route_table_association" "My_VPC_RT_association_AZ_2B" {
  subnet_id      = aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  route_table_id = aws_route_table.My_VPC_RT.id
}


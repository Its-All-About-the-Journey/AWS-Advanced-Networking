resource "aws_vpc" "Consumer_VPC" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "Consumer_VPC"
  }
}

resource "aws_internet_gateway" "Consumer_VPC_IGW" {
  vpc_id = aws_vpc.Consumer_VPC.id

  tags = {
    "name" = "Consumer_VPC_IGW"
  }
}

resource "aws_subnet" "public_subnet_for_Consumer_VPC_AZ_2A" {
  vpc_id                  = aws_vpc.Consumer_VPC.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "us-west-2a"

  tags = {
    Name = "public_subnet_for_Consumer_VPC_AZ_2A"
  }
}

resource "aws_security_group" "Consumer_VPC_SG" {
  name        = "Consumer_VPC_SG"
  description = "Allow TLS, HTTP, and SSH inbound traffic"
  vpc_id      = aws_vpc.Consumer_VPC.id

  ingress {
    description = "TLS into VPC"
    from_port   = 443
    to_port     = 443
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
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
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
    Name = "Consumer_VPC_SG"
  }
}

resource "aws_route_table" "Consumer_VPC_RT" {
  vpc_id = aws_vpc.Consumer_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Consumer_VPC_IGW.id
  }

  tags = {
    Name = "Consumer_VPC_RT"
  }
}

resource "aws_route_table_association" "Consumer_VPC_RT_association" {
  subnet_id      = aws_subnet.public_subnet_for_Consumer_VPC_AZ_2A.id
  route_table_id = aws_route_table.Consumer_VPC_RT.id
}

resource "aws_vpc_endpoint_service" "vpc_endpoint_service" {
  acceptance_required        = false
  network_load_balancer_arns = [aws_lb.network_load_balancer.arn]
}

resource "aws_vpc_endpoint" "vpce" {
  auto_accept       = true
  vpc_id            = aws_vpc.Consumer_VPC.id
  service_name      = aws_vpc_endpoint_service.vpc_endpoint_service.service_name
  vpc_endpoint_type = "Interface"
  subnet_ids        = [aws_subnet.public_subnet_for_Consumer_VPC_AZ_2A.id]

  security_group_ids = [aws_security_group.Consumer_VPC_SG.id]
}


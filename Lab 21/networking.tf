resource "aws_vpc" "VPC" {
  cidr_block                       = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true # /56 is the default.
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true

  tags = {
    Name = "VPC"
  }
}

resource "aws_subnet" "Public_A" {
  vpc_id                          = aws_vpc.VPC.id
  cidr_block                      = "10.0.0.0/24"
  availability_zone               = "us-west-2a"
  assign_ipv6_address_on_creation = true

  # 8: This is the number of bits to shift forward from the right end of the original CIDR block. 
  # In this case, it's shifting 8 bits to the right. /64 is the default.
  # 0: This creates the first subnet.
  ipv6_cidr_block = cidrsubnet(aws_vpc.VPC.ipv6_cidr_block, 8, 0)

  tags = {
    Name = "Public_A"
  }
}

resource "aws_subnet" "Public_B" {
  vpc_id                          = aws_vpc.VPC.id
  cidr_block                      = "10.0.1.0/24"
  availability_zone               = "us-west-2b"
  assign_ipv6_address_on_creation = true
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.VPC.ipv6_cidr_block, 8, 1)

  tags = {
    Name = "Public_B"
  }
}

resource "aws_subnet" "Private_A" {
  vpc_id                          = aws_vpc.VPC.id
  cidr_block                      = "10.0.2.0/24"
  availability_zone               = "us-west-2a"
  assign_ipv6_address_on_creation = true
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.VPC.ipv6_cidr_block, 8, 2)

  tags = {
    Name = "Private_A"
  }
}

resource "aws_subnet" "Private_B" {
  vpc_id                          = aws_vpc.VPC.id
  cidr_block                      = "10.0.3.0/24"
  availability_zone               = "us-west-2b"
  assign_ipv6_address_on_creation = true
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.VPC.ipv6_cidr_block, 8, 3)

  tags = {
    Name = "Private_B"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_egress_only_internet_gateway" "EIGW" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "EIGW"
  }
}

resource "aws_route_table" "Public_A_and_B_RT" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "Public_A_and_B_RT"
  }
}

resource "aws_route_table_association" "Public_A_and_B_RTA1" {
  subnet_id      = aws_subnet.Public_A.id
  route_table_id = aws_route_table.Public_A_and_B_RT.id
}

resource "aws_route_table_association" "Public_A_and_B_RTA2" {
  subnet_id      = aws_subnet.Public_B.id
  route_table_id = aws_route_table.Public_A_and_B_RT.id
}

resource "aws_eip" "NGW1" {
  domain = "vpc"

  tags = {
    "Name" = "NGW1"
  }
}

resource "aws_nat_gateway" "NGW1" {
  allocation_id = aws_eip.NGW1.id
  subnet_id     = aws_subnet.Public_A.id

  tags = {
    Name = "NGW1"
  }

  depends_on = [aws_internet_gateway.IGW]
}

resource "aws_eip" "NGW2" {
  domain = "vpc"

  tags = {
    "Name" = "NGW2"
  }
}

resource "aws_nat_gateway" "NGW2" {
  allocation_id = aws_eip.NGW2.id
  subnet_id     = aws_subnet.Public_B.id

  tags = {
    Name = "NGW2"
  }

  depends_on = [aws_internet_gateway.IGW]
}


resource "aws_route_table" "Private_A_RT" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NGW1.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.EIGW.id
  }

  tags = {
    Name = "Private_A_RT"
  }
}

resource "aws_route_table_association" "Private_A_RTA" {
  subnet_id      = aws_subnet.Private_A.id
  route_table_id = aws_route_table.Private_A_RT.id
}

resource "aws_route_table" "Private_B_RT" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NGW2.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.EIGW.id
  }

  tags = {
    Name = "Private_B_RT"
  }
}

resource "aws_route_table_association" "Private_B_RTA" {
  subnet_id      = aws_subnet.Private_B.id
  route_table_id = aws_route_table.Private_B_RT.id
}

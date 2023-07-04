resource "aws_vpc" "Egress_VPC" {
  cidr_block = "10.3.0.0/16"
}

resource "aws_internet_gateway" "Egress_VPC_IGW" {
  vpc_id = aws_vpc.Egress_VPC.id

  tags = {
    Name = "Egress_VPC_IGW"
  }
}

resource "aws_subnet" "Egress_VPC_TGW_Subnet" {
  vpc_id            = aws_vpc.Egress_VPC.id
  cidr_block        = "10.3.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Egress_VPC_TGW_Subnet"
  }
}

resource "aws_subnet" "Egress_VPC_NGW_Subnet" {
  vpc_id            = aws_vpc.Egress_VPC.id
  cidr_block        = "10.3.2.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Egress_VPC_NGW_Subnet"
  }
}

resource "aws_route_table" "Egress_VPC_TGW_RT" {
  vpc_id = aws_vpc.Egress_VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NGW.id
  }

  tags = {
    Name = "Egress_VPC_TGW_RT"
  }
}

resource "aws_route_table" "Egress_VPC_NGW_RT" {
  vpc_id = aws_vpc.Egress_VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Egress_VPC_IGW.id
  }

  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  }

  tags = {
    Name = "Egress_VPC_NGW_RT"
  }
}

resource "aws_route_table_association" "Egress_VPC_RTA_1" {
  subnet_id      = aws_subnet.Egress_VPC_TGW_Subnet.id
  route_table_id = aws_route_table.Egress_VPC_TGW_RT.id
}

resource "aws_route_table_association" "Egress_VPC_RTA_2" {
  subnet_id      = aws_subnet.Egress_VPC_NGW_Subnet.id
  route_table_id = aws_route_table.Egress_VPC_NGW_RT.id
}

resource "aws_eip" "NGW" {
  domain = "vpc"

  tags = {
    Name = "NGW"
  }
}

resource "aws_nat_gateway" "NGW" {
  allocation_id = aws_eip.NGW.id
  subnet_id     = aws_subnet.Egress_VPC_NGW_Subnet.id

  tags = {
    Name = "NGW"
  }
}

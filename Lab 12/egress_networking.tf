resource "aws_vpc" "Egress_VPC" {
  cidr_block = "10.3.0.0/16"
}

resource "aws_internet_gateway" "Egress_VPC_IGW" {
  vpc_id = aws_vpc.Egress_VPC.id

  tags = {
    Name = "Egress_VPC_IGW"
  }
}

resource "aws_subnet" "Egress_VPC_TGW_Subnet_1_AZ_A" {
  vpc_id            = aws_vpc.Egress_VPC.id
  cidr_block        = "10.3.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Egress_VPC_TGW_Subnet_1_AZ_A"
  }
}

resource "aws_subnet" "Egress_VPC_TGW_Subnet_2_AZ_B" {
  vpc_id            = aws_vpc.Egress_VPC.id
  cidr_block        = "10.3.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "Egress_VPC_TGW_Subnet_2_AZ_B"
  }
}

resource "aws_subnet" "Egress_VPC_NGW_Subnet_1_AZ_A" {
  vpc_id            = aws_vpc.Egress_VPC.id
  cidr_block        = "10.3.3.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Egress_VPC_NGW_Subnet_1_AZ_A"
  }
}

resource "aws_subnet" "Egress_VPC_NGW_Subnet_2_AZ_B" {
  vpc_id            = aws_vpc.Egress_VPC.id
  cidr_block        = "10.3.4.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "Egress_VPC_NGW_Subnet_2_AZ_B"
  }
}

resource "aws_route_table" "Egress_VPC_TGW_RT_1" {
  vpc_id = aws_vpc.Egress_VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NGW_1.id
  }

  tags = {
    Name = "Egress_VPC_TGW_RT_1"
  }
}

resource "aws_route_table" "Egress_VPC_TGW_RT_2" {
  vpc_id = aws_vpc.Egress_VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NGW_2.id
  }

  tags = {
    Name = "Egress_VPC_TGW_RT_2"
  }
}

resource "aws_route_table" "Egress_VPC_NGW_RT_1" {
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
    Name = "Egress_VPC_NGW_RT_1"
  }
}

resource "aws_route_table" "Egress_VPC_NGW_RT_2" {
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
    Name = "Egress_VPC_NGW_RT_2"
  }
}

resource "aws_route_table_association" "Egress_VPC_RTA_1" {
  subnet_id      = aws_subnet.Egress_VPC_TGW_Subnet_1_AZ_A.id
  route_table_id = aws_route_table.Egress_VPC_TGW_RT_1.id
}

resource "aws_route_table_association" "Egress_VPC_RTA_2" {
  subnet_id      = aws_subnet.Egress_VPC_TGW_Subnet_2_AZ_B.id
  route_table_id = aws_route_table.Egress_VPC_TGW_RT_2.id
}

resource "aws_route_table_association" "Egress_VPC_RTA_3" {
  subnet_id      = aws_subnet.Egress_VPC_NGW_Subnet_1_AZ_A.id
  route_table_id = aws_route_table.Egress_VPC_NGW_RT_1.id
}

resource "aws_route_table_association" "Egress_VPC_RTA_4" {
  subnet_id      = aws_subnet.Egress_VPC_NGW_Subnet_2_AZ_B.id
  route_table_id = aws_route_table.Egress_VPC_NGW_RT_2.id
}

resource "aws_eip" "NGW_1" {
  domain = "vpc"

  tags = {
    Name = "NGW_1"
  }
}

resource "aws_eip" "NGW_2" {
  domain = "vpc"

  tags = {
    Name = "NGW_2"
  }
}

resource "aws_nat_gateway" "NGW_1" {
  allocation_id = aws_eip.NGW_1.id
  subnet_id     = aws_subnet.Egress_VPC_NGW_Subnet_1_AZ_A.id

  tags = {
    Name = "NGW_1"
  }
}

resource "aws_nat_gateway" "NGW_2" {
  allocation_id = aws_eip.NGW_2.id
  subnet_id     = aws_subnet.Egress_VPC_NGW_Subnet_2_AZ_B.id

  tags = {
    Name = "NGW_2"
  }
}

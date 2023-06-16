resource "aws_vpc" "VPC_A" {
  cidr_block       = "192.168.0.0/16"
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

resource "aws_subnet" "public_subnet_for_VPC_A_AZ_2A" {
  vpc_id            = aws_vpc.VPC_A.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "public_subnet_for_VPC_A_AZ_2A"
  }
}

resource "aws_route_table" "VPC_A_Public_RT" {
  vpc_id = aws_vpc.VPC_A.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_A_IGW.id
  }

  propagating_vgws = [aws_vpn_gateway.VPC_A_VPGW.id]

  tags = {
    Name = "VPC_A_Public_RT"
  }
}

resource "aws_route_table_association" "VPC_A_Public_RT_association" {
  subnet_id      = aws_subnet.public_subnet_for_VPC_A_AZ_2A.id
  route_table_id = aws_route_table.VPC_A_Public_RT.id
}

resource "aws_customer_gateway" "CGW" {
  bgp_asn     = 65000
  ip_address  = data.aws_eip.CGW_EIP.public_ip
  type        = "ipsec.1"
  device_name = "CGW"

  tags = {
    Name = "CGW"
  }
}


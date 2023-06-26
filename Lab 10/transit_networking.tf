resource "aws_vpc" "Connect_VPC" {
  cidr_block = "172.31.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "Connect_VPC"
  }
}

resource "aws_subnet" "public_subnet_1_for_Connect_VPC_AZ_2A" {
  vpc_id            = aws_vpc.Connect_VPC.id
  cidr_block        = "172.31.0.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "public_subnet_1_for_Connect_VPC_AZ_2A"
  }
}

resource "aws_subnet" "public_subnet_2_for_Connect_VPC_AZ_2A" {
  vpc_id            = aws_vpc.Connect_VPC.id
  cidr_block        = "172.31.1.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "public_subnet_2_for_Connect_VPC_AZ_2A"
  }
}

resource "aws_internet_gateway" "Connect_VPC_IGW" {
  vpc_id = aws_vpc.Connect_VPC.id

  tags = {
    "name" = "Connect_VPC_IGW"
  }
}

resource "aws_route_table" "Connect_VPC_RT" {
  vpc_id = aws_vpc.Connect_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Connect_VPC_IGW.id
  }

  route {
    cidr_block = "10.0.1.0/24"
    transit_gateway_id = aws_ec2_transit_gateway.SD-WAN.id
  }
  
  route {
    cidr_block = "192.0.2.0/24"
    transit_gateway_id = aws_ec2_transit_gateway.SD-WAN.id
  }

  route {
    cidr_block = "169.254.0.0/16"
    transit_gateway_id = aws_ec2_transit_gateway.SD-WAN.id
  }

  tags = {
    Name = "Connect_VPC_RT"
  }
}

resource "aws_route_table_association" "Connect_VPC_RTA_1" {
  subnet_id      = aws_subnet.public_subnet_1_for_Connect_VPC_AZ_2A.id
  route_table_id = aws_route_table.Connect_VPC_RT.id
}

resource "aws_route_table_association" "Connect_VPC_RTA_2" {
  subnet_id      = aws_subnet.public_subnet_2_for_Connect_VPC_AZ_2A.id
  route_table_id = aws_route_table.Connect_VPC_RT.id
}

resource "aws_eip" "CSR_1_EIP" {
  vpc = true
}

resource "aws_eip_association" "CSR_1_EIP_Assoc" {
  allocation_id        = aws_eip.CSR_1_EIP.id
  network_interface_id = aws_network_interface.Public_Network_Interface.id
}

resource "aws_eip" "CSR_2_EIP" {
  vpc = true
}

resource "aws_eip_association" "CSR_2_EIP_Assoc" {
  allocation_id        = aws_eip.CSR_2_EIP.id
  network_interface_id = aws_network_interface.Public_Network_Interface_2.id
}

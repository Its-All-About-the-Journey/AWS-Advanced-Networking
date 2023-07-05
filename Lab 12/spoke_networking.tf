resource "aws_vpc" "VPC_A" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_subnet" "VPC_A_Workload_and_TGW_Subnet" {
  vpc_id            = aws_vpc.VPC_A.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "VPC_A_Workload_and_TGW_Subnet"
  }
}

resource "aws_route_table" "VPC_A_RT" {
  vpc_id = aws_vpc.VPC_A.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  }

  tags = {
    Name = "VPC_A_RT"
  }
}

resource "aws_route_table_association" "VPC_A_RTA" {
  subnet_id      = aws_subnet.VPC_A_Workload_and_TGW_Subnet.id
  route_table_id = aws_route_table.VPC_A_RT.id
}


resource "aws_vpc" "VPC_B" {
  cidr_block = "10.2.0.0/16"
}

resource "aws_subnet" "VPC_B_Workload_and_TGW_Subnet" {
  vpc_id     = aws_vpc.VPC_B.id
  cidr_block = "10.2.1.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "VPC_B_Workload_and_TGW_Subnet"
  }
}

resource "aws_route_table" "VPC_B_RT" {
  vpc_id = aws_vpc.VPC_B.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  }

  tags = {
    Name = "VPC_B_RT"
  }
}

resource "aws_route_table_association" "VPC_B_RTA_" {
  subnet_id      = aws_subnet.VPC_B_Workload_and_TGW_Subnet.id
  route_table_id = aws_route_table.VPC_B_RT.id
}

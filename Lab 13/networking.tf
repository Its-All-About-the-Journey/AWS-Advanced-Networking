resource "aws_vpc" "VPC" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_subnet" "Firewall_Subnet" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Firewall_Subnet"
  }
}

resource "aws_subnet" "Public_Subnet" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Public_Subnet"
  }
}

resource "aws_subnet" "Private_Subnet" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "Private_Subnet"
  }
}

resource "aws_route_table" "IGW_RT" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "10.0.2.0/24"
    network_interface_id = data.aws_network_interface.ENI_0.id
  }

  tags = {
    Name = "IGW_RT"
  }
}

resource "aws_route_table_association" "IGW_RTA" {
  gateway_id     = aws_internet_gateway.IGW.id
  route_table_id = aws_route_table.IGW_RT.id
}

resource "aws_route_table" "Public_RT" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = data.aws_network_interface.ENI_0.id
  }

  tags = {
    Name = "Public_RT"
  }

}

resource "aws_route_table_association" "Public_RTA" {
  subnet_id      = aws_subnet.Public_Subnet.id
  route_table_id = aws_route_table.Public_RT.id
}

resource "aws_route_table" "Private_RT" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NGW.id
  }

  tags = {
    Name = "Private_RT"
  }
}

resource "aws_route_table_association" "Private_RTA" {
  subnet_id      = aws_subnet.Private_Subnet.id
  route_table_id = aws_route_table.Private_RT.id
}

resource "aws_route_table" "Firewall_RT" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "Firewall_RT"
  }

}

resource "aws_route_table_association" "Firewall_RTA" {
  subnet_id      = aws_subnet.Firewall_Subnet.id
  route_table_id = aws_route_table.Firewall_RT.id
}



resource "aws_eip" "NGW" {
  domain = "vpc"

  tags = {
    Name = "NGW"
  }
}

resource "aws_nat_gateway" "NGW" {
  allocation_id = aws_eip.NGW.id
  subnet_id     = aws_subnet.Public_Subnet.id

  tags = {
    Name = "NGW"
  }
}

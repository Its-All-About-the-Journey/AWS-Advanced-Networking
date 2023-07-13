resource "aws_vpc" "Shared_VPC" {
  cidr_block = "10.1.0.0/16"
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.Shared_VPC.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_subnet" "Firewall_Subnet_Acct_A" {
  vpc_id     = aws_vpc.Shared_VPC.id
  cidr_block = "10.1.1.0/24"

  tags = {
    Name = "Firewall_Subnet_Acct_A"
  }
}

resource "aws_subnet" "Public_Subnet_Acct_A" {
  vpc_id     = aws_vpc.Shared_VPC.id
  cidr_block = "10.1.2.0/24"

  tags = {
    Name = "Public_Subnet_Acct_A"
  }
}

resource "aws_subnet" "Private_Subnet_Acct_B" {
  vpc_id     = aws_vpc.Shared_VPC.id
  cidr_block = "10.1.3.0/24"

  tags = {
    Name = "Private_Subnet_Acct_B"
  }
}

resource "aws_route_table" "IGW_RT" {
  vpc_id = aws_vpc.Shared_VPC.id

  route {
    cidr_block = "10.1.2.0/24"
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
  vpc_id = aws_vpc.Shared_VPC.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = data.aws_network_interface.ENI_0.id
  }

  tags = {
    Name = "Public_RT"
  }

}

resource "aws_route_table_association" "Public_RTA" {
  subnet_id      = aws_subnet.Public_Subnet_Acct_A.id
  route_table_id = aws_route_table.Public_RT.id
}

resource "aws_route_table" "Private_RT" {
  vpc_id = aws_vpc.Shared_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NGW.id
  }

  tags = {
    Name = "Private_RT"
  }
}

resource "aws_route_table_association" "Private_RTA" {
  subnet_id      = aws_subnet.Private_Subnet_Acct_B.id
  route_table_id = aws_route_table.Private_RT.id
}

resource "aws_route_table" "Firewall_RT" {
  vpc_id = aws_vpc.Shared_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "Firewall_RT"
  }

}

resource "aws_eip" "NGW" {
  domain = "vpc"

  tags = {
    Name = "NGW"
  }
}

resource "aws_nat_gateway" "NGW" {
  allocation_id = aws_eip.NGW.id
  subnet_id     = aws_subnet.Public_Subnet_Acct_A.id

  tags = {
    Name = "NGW"
  }
}

resource "aws_route_table_association" "Firewall_RTA" {
  subnet_id      = aws_subnet.Firewall_Subnet_Acct_A.id
  route_table_id = aws_route_table.Firewall_RT.id
}

resource "aws_ram_resource_share" "Resource_Access_Manager" {
  name                      = "Resource_Access_Manager"
  allow_external_principals = false

  tags = {
    Name = "Resource_Access_Manager"
  }
}

resource "aws_ram_resource_association" "Private_Subnet_Acct_B" {
  resource_arn       = aws_subnet.Private_Subnet_Acct_B.arn
  resource_share_arn = aws_ram_resource_share.Resource_Access_Manager.arn
}

resource "aws_ram_principal_association" "sender_invite" {
  # Sends an invite to Account B. It auto accepts since its under the same organization.
  principal          = data.aws_caller_identity.receiver.account_id

  resource_share_arn = aws_ram_resource_share.Resource_Access_Manager.arn
}


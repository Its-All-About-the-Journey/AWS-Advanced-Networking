resource "aws_vpc" "VPC_A" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support = true

  provider = aws.Account_1

  tags = {
    Name = "VPC_A"
  }
}

resource "aws_vpc" "VPC_B" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"

  provider = aws.Account_1

  tags = {
    Name = "VPC_B"
  }
}

resource "aws_internet_gateway" "VPC_A_IGW" {
  vpc_id = aws_vpc.VPC_A.id

  provider = aws.Account_1

  tags = {
    "name" = "VPC_A_IGW"
  }
}

resource "aws_internet_gateway" "VPC_B_IGW" {
  vpc_id = aws_vpc.VPC_B.id

  provider = aws.Account_1

  tags = {
    "name" = "VPC_B_IGW"
  }
}


resource "aws_subnet" "public_subnet_for_VPC_A_AZ_2A" {
  vpc_id            = aws_vpc.VPC_A.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "us-west-2a"

  provider = aws.Account_1

  tags = {
    Name = "public_subnet_for_VPC_A_AZ_2A"
  }
}

resource "aws_subnet" "public_subnet_for_VPC_B_AZ_2A" {
  vpc_id            = aws_vpc.VPC_B.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-west-2a"

  provider = aws.Account_1

  tags = {
    Name = "public_subnet_for_VPC_B_AZ_2A"
  }
}

resource "aws_subnet" "private_subnet_for_VPC_A_AZ_2A" {
  vpc_id            = aws_vpc.VPC_A.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "us-west-2a"

  provider = aws.Account_1

  tags = {
    Name = "private_subnet_for_VPC_A_AZ_2A"
  }
}

resource "aws_subnet" "private_subnet_for_VPC_B_AZ_2A" {
  vpc_id            = aws_vpc.VPC_B.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "us-west-2a"

  provider = aws.Account_1

  tags = {
    Name = "private_subnet_for_VPC_B_AZ_2A"
  }
}

resource "aws_route_table" "VPC_A_Public_RT" {
  vpc_id = aws_vpc.VPC_A.id

  provider = aws.Account_1

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_A_IGW.id
  }

  tags = {
    Name = "VPC_A_Public_RT"
  }
}

resource "aws_route_table" "VPC_B_Public_RT" {
  vpc_id = aws_vpc.VPC_B.id

  provider = aws.Account_1

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_B_IGW.id
  }

  tags = {
    Name = "VPC_B_Public_RT"
  }
}

resource "aws_route_table" "VPC_A_Private_RT" {
  vpc_id = aws_vpc.VPC_A.id

  provider = aws.Account_1

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.VPC_A_NGW.id
  }

  route {
    cidr_block                = "10.1.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.VPC_A_and_B_Peering.id
  }

  route {
    cidr_block                = "172.20.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.VPC_A_Acct_1_and_VPC_A_Acct_2_Peering.id
  }

  tags = {
    Name = "VPC_A_Private_RT"
  }
}

resource "aws_route_table" "VPC_B_Private_RT" {
  vpc_id = aws_vpc.VPC_B.id

  provider = aws.Account_1

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.VPC_B_NGW.id
  }

  route {
    cidr_block                = "192.168.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.VPC_A_and_B_Peering.id
  }

  tags = {
    Name = "VPC_B_Private_RT"
  }
}

resource "aws_route_table_association" "VPC_A_Private_RT_association" {
  subnet_id      = aws_subnet.private_subnet_for_VPC_A_AZ_2A.id
  route_table_id = aws_route_table.VPC_A_Private_RT.id

  provider = aws.Account_1
}

resource "aws_route_table_association" "VPC_B_Private_RT_association" {
  subnet_id      = aws_subnet.private_subnet_for_VPC_B_AZ_2A.id
  route_table_id = aws_route_table.VPC_B_Private_RT.id

  provider = aws.Account_1
}

resource "aws_route_table_association" "VPC_A_Public_RT_association" {
  subnet_id      = aws_subnet.public_subnet_for_VPC_A_AZ_2A.id
  route_table_id = aws_route_table.VPC_A_Public_RT.id

  provider = aws.Account_1
}

resource "aws_route_table_association" "VPC_B_Public_RT_association" {
  subnet_id      = aws_subnet.public_subnet_for_VPC_B_AZ_2A.id
  route_table_id = aws_route_table.VPC_B_Public_RT.id

  provider = aws.Account_1
}

# ----------------------------------------------------------------------------------------------
resource "aws_eip" "VPC_A_EIP" {
  vpc = true

  provider = aws.Account_1
}

resource "aws_eip" "VPC_B_EIP" {
  vpc = true

  provider = aws.Account_1
}

resource "aws_nat_gateway" "VPC_A_NGW" {
  allocation_id     = aws_eip.VPC_A_EIP.id
  subnet_id         = aws_subnet.public_subnet_for_VPC_A_AZ_2A.id
  connectivity_type = "public"

  provider = aws.Account_1
}

resource "aws_nat_gateway" "VPC_B_NGW" {
  allocation_id     = aws_eip.VPC_B_EIP.id
  subnet_id         = aws_subnet.public_subnet_for_VPC_B_AZ_2A.id
  connectivity_type = "public"

  provider = aws.Account_1
}

# ----------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------
# VPC_A and VPC_B VPC Peering
resource "aws_vpc_peering_connection" "VPC_A_and_B_Peering" {
  peer_owner_id = var.peer_owner_id_acct_1
  peer_vpc_id   = aws_vpc.VPC_A.id # VPC Accepter; server
  vpc_id        = aws_vpc.VPC_B.id # VPC Requester; client
  auto_accept   = true

  provider = aws.Account_1

  tags = {
    Name = "VPC Peering between VPC_A and VPC_B"
  }
}
# ----------------------------------------------------------------------------------------------

# Requester's side of the connection.
resource "aws_vpc_peering_connection" "VPC_A_Acct_1_and_VPC_A_Acct_2_Peering" {
  vpc_id        = aws_vpc.VPC_A_Acct_2.id # VPC Peering Requester; source. Can be in the same account or another.
  provider      = aws.Account_2 # Allows the Requester VPC in another account to be appied into the resource

  peer_owner_id = var.peer_owner_id_acct_1 # The account who creates the VPC Peering
  peer_vpc_id   = aws_vpc.VPC_A.id        # VPC Peering Accepter; destination.

  tags = {
    Name = "VPC_A_Acct_1_and_VPC_A_Acct_2_Peering"
    Side = "Requester"
  }
}

# Accepter's side of the connection. Which is VPC A_Acct_1
resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = aws_vpc_peering_connection.VPC_A_Acct_1_and_VPC_A_Acct_2_Peering.id
  auto_accept = true
  provider = aws.Account_1

  tags = {
    Side = "Accepter"
  }
}

resource "aws_vpc_peering_connection_options" "Requester" {
  vpc_peering_connection_id = aws_vpc_peering_connection.VPC_A_Acct_1_and_VPC_A_Acct_2_Peering.id
  provider = aws.Account_1 # For some weird reason, using the Accepter Account here works.

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  # Dependency required on the two accepter resources
  depends_on = [ aws_vpc_peering_connection_options.Accepter, aws_vpc_peering_connection_accepter.peer ]

}

resource "aws_vpc_peering_connection_options" "Accepter" {
  provider                  = aws.Account_1
  vpc_peering_connection_id = aws_vpc_peering_connection.VPC_A_Acct_1_and_VPC_A_Acct_2_Peering.id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  
  # Add a dependency to the connection accepter. It contains details on the active status state
  depends_on = [ aws_vpc_peering_connection_accepter.peer ]

}

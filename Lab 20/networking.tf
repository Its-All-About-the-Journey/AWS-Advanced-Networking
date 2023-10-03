resource "aws_vpc" "VPC_A" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC_A"
  }
}

resource "aws_subnet" "Public_A" {
  vpc_id                  = aws_vpc.VPC_A.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"

  tags = {
    Name = "Public_A"
  }
}

resource "aws_internet_gateway" "VPC_A" {
  vpc_id = aws_vpc.VPC_A.id

  tags = {
    Name = "VPC_A"
  }  
}

resource "aws_route_table" "VPC_A_RT" {
  vpc_id = aws_vpc.VPC_A.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_A.id
  }

  route {
    cidr_block                = "10.1.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.VPC_A_and_B_Peering.id
  }

  tags = {
    Name = "VPC_A_RT"
  }
}

resource "aws_route_table_association" "VPC_A_RTA" {
  subnet_id      = aws_subnet.Public_A.id
  route_table_id = aws_route_table.VPC_A_RT.id
}

resource "aws_vpc" "VPC_B" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC_B"
  }
}

resource "aws_subnet" "Public_B" {
  vpc_id                  = aws_vpc.VPC_B.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "us-west-2a"

  tags = {
    Name = "Public_B"
  }
}

resource "aws_internet_gateway" "VPC_B" {
  vpc_id = aws_vpc.VPC_B.id

  tags = {
    Name = "VPC_B"
  }  
}

resource "aws_route_table" "VPC_B_RT" {
  vpc_id = aws_vpc.VPC_B.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_B.id
  }

  route {
    cidr_block                = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.VPC_A_and_B_Peering.id
  }

  tags = {
    Name = "VPC_B_RT"
  }
}

resource "aws_route_table_association" "VPC_B_RTA" {
  subnet_id      = aws_subnet.Public_B.id
  route_table_id = aws_route_table.VPC_B_RT.id
}

# ----------------------------------------------------------------------------------------------

# VPC_A and VPC_B VPC Peering
resource "aws_vpc_peering_connection" "VPC_A_and_B_Peering" {
  peer_owner_id = data.aws_caller_identity.Account.account_id
  peer_vpc_id   = aws_vpc.VPC_A.id # VPC Accepter; server
  vpc_id        = aws_vpc.VPC_B.id # VPC Requester; client
  auto_accept   = true

  tags = {
    Name = "VPC Peering between VPC_A and VPC_B"
  }
}

# ----------------------------------------------------------------------------------------------

resource "aws_ec2_traffic_mirror_target" "target" {
  description          = "ENI target"
  network_interface_id = aws_instance.VPC_A[1].primary_network_interface_id

  tags = {
    "Name" = "target"
  }
}

resource "aws_ec2_traffic_mirror_filter" "ICMP" {
  description      = "traffic mirror filter"

  tags = {
    "Name" = "ICMP"
  }
}

resource "aws_ec2_traffic_mirror_filter_rule" "rulein" {
  description              = "ICMP rule"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.ICMP.id
  destination_cidr_block   = "10.1.0.0/16"
  source_cidr_block        = "10.0.0.0/16"
  rule_number              = 1
  rule_action              = "accept"
  traffic_direction        = "ingress"
  protocol                 = 1
}

resource "aws_ec2_traffic_mirror_filter_rule" "ruleout" {
  description              = "ICMP rule"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.ICMP.id
  destination_cidr_block   = "10.0.0.0/16"
  source_cidr_block        = "10.1.0.0/16"
  rule_number              = 1
  rule_action              = "accept"
  traffic_direction        = "egress"
  protocol                 = 1
}

resource "aws_ec2_traffic_mirror_session" "session" {
  description              = "traffic mirror session"
  network_interface_id     = aws_instance.VPC_B.primary_network_interface_id
  session_number           = 1
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.ICMP.id
  traffic_mirror_target_id = aws_ec2_traffic_mirror_target.target.id

  tags = {
    "Name" = "sesion"
  }
}

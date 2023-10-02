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
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.TGW.id
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
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  }

  tags = {
    Name = "VPC_B_RT"
  }
}

resource "aws_route_table_association" "VPC_B_RTA" {
  subnet_id      = aws_subnet.Public_B.id
  route_table_id = aws_route_table.VPC_B_RT.id
}

resource "aws_vpc" "VPC_C" {
  provider = aws.Account_B
  cidr_block       = "10.2.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC_C"
  }
}

resource "aws_subnet" "Public_C" {
  provider = aws.Account_B
  vpc_id                  = aws_vpc.VPC_C.id
  cidr_block              = "10.2.1.0/24"
  availability_zone       = "us-west-2a"

  tags = {
    Name = "Public_C"
  }
}

resource "aws_internet_gateway" "VPC_C" {
  provider = aws.Account_B
  vpc_id = aws_vpc.VPC_C.id

  tags = {
    Name = "VPC_C"
  }  
}

resource "aws_route_table" "VPC_C_RT" {
  provider = aws.Account_B
  vpc_id = aws_vpc.VPC_C.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_C.id
  }

  route {
    cidr_block = "10.0.0.0/8"
    transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  }

  depends_on = [ 
    aws_ram_principal_association.sender_invite, 
    aws_ram_resource_association.TGW
  ]

  tags = {
    Name = "VPC_C_RT"
  }
}

resource "aws_route_table_association" "VPC_C_RTA" {
  provider = aws.Account_B
  subnet_id      = aws_subnet.Public_C.id
  route_table_id = aws_route_table.VPC_C_RT.id
}

# ---------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway" "TGW" {
  description                     = "TGW"
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  multicast_support = "enable"
  vpn_ecmp_support = "disable"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "VPC_A" {
  subnet_ids         = [aws_subnet.Public_A.id]
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  vpc_id             = aws_vpc.VPC_A.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "VPC_B" {
  subnet_ids         = [aws_subnet.Public_B.id]
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  vpc_id             = aws_vpc.VPC_B.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "VPC_C" {
  provider = aws.Account_B
  subnet_ids         = [aws_subnet.Public_C.id]
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  vpc_id             = aws_vpc.VPC_C.id

  # Executes after the sharing has been completed
  depends_on = [ aws_ram_principal_association.sender_invite, aws_ram_resource_association.TGW ]
}

resource "aws_ec2_transit_gateway_multicast_domain" "domain" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  auto_accept_shared_associations = "enable"
  igmpv2_support = "enable"

  tags = {
    Name = "Transit_Gateway_Multicast_Domain"
  }
}

resource "aws_ec2_transit_gateway_multicast_domain_association" "association1" {
  subnet_id                           = aws_subnet.Public_A.id
  transit_gateway_attachment_id       = aws_ec2_transit_gateway_vpc_attachment.VPC_A.id
  transit_gateway_multicast_domain_id = aws_ec2_transit_gateway_multicast_domain.domain.id
}

resource "aws_ec2_transit_gateway_multicast_domain_association" "association2" {
  subnet_id                           = aws_subnet.Public_B.id
  transit_gateway_attachment_id       = aws_ec2_transit_gateway_vpc_attachment.VPC_B.id
  transit_gateway_multicast_domain_id = aws_ec2_transit_gateway_multicast_domain.domain.id
}

resource "aws_ec2_transit_gateway_multicast_domain_association" "association3" {
  provider = aws.Account_B
  subnet_id                           = aws_subnet.Public_C.id
  transit_gateway_attachment_id       = aws_ec2_transit_gateway_vpc_attachment.VPC_C.id
  transit_gateway_multicast_domain_id = aws_ec2_transit_gateway_multicast_domain.domain.id

  # Executes after the sharing has been completed
  depends_on = [ 
    aws_ram_principal_association.sender_invite, 
    aws_ram_resource_association.TGW,
    aws_ram_resource_association.Multicast_Domain
  ]
}

resource "aws_ec2_transit_gateway_multicast_group_member" "Member_1a" {
  group_ip_address                    = "224.0.0.100"
  network_interface_id                = aws_instance.VPC_A.primary_network_interface_id
  transit_gateway_multicast_domain_id = aws_ec2_transit_gateway_multicast_domain_association.association1.transit_gateway_multicast_domain_id
}

resource "aws_ec2_transit_gateway_multicast_group_member" "Member_1b" {
  group_ip_address                    = "224.0.0.100"
  network_interface_id                = aws_instance.VPC_B[0].primary_network_interface_id
  transit_gateway_multicast_domain_id = aws_ec2_transit_gateway_multicast_domain_association.association2.transit_gateway_multicast_domain_id
}

resource "aws_ec2_transit_gateway_multicast_group_member" "Member_1c" {
  group_ip_address                    = "224.0.0.100"
  network_interface_id                = aws_instance.VPC_B[1].primary_network_interface_id
  transit_gateway_multicast_domain_id = aws_ec2_transit_gateway_multicast_domain_association.association2.transit_gateway_multicast_domain_id
}

resource "aws_ec2_transit_gateway_multicast_group_member" "Member_2a" {
  group_ip_address                    = "224.0.0.251"
  network_interface_id                = aws_instance.VPC_B[1].primary_network_interface_id
  transit_gateway_multicast_domain_id = aws_ec2_transit_gateway_multicast_domain_association.association2.transit_gateway_multicast_domain_id
}

resource "aws_ec2_transit_gateway_multicast_group_member" "Member_2b" {
  provider = aws.Account_B
  group_ip_address                    = "224.0.0.251"
  network_interface_id                = aws_instance.VPC_C.primary_network_interface_id
  transit_gateway_multicast_domain_id = aws_ec2_transit_gateway_multicast_domain_association.association3.transit_gateway_multicast_domain_id
}

# ---------------------------------------------------------------------------------

resource "aws_ram_resource_share" "Resource_Access_Manager" {
  name                      = "Resource_Access_Manager"
  allow_external_principals = false

  tags = {
    Name = "Resource_Access_Manager"
  }
}

resource "aws_ram_resource_association" "TGW" {
  resource_arn       = aws_ec2_transit_gateway.TGW.arn
  resource_share_arn = aws_ram_resource_share.Resource_Access_Manager.arn

  depends_on = [ aws_ram_principal_association.sender_invite ]
}

resource "aws_ram_resource_association" "Multicast_Domain" {
  resource_arn       = aws_ec2_transit_gateway_multicast_domain.domain.arn
  resource_share_arn = aws_ram_resource_share.Resource_Access_Manager.arn

  depends_on = [ aws_ram_principal_association.sender_invite ]
}

resource "aws_ram_principal_association" "sender_invite" {
  # Sends an invite to Account B. It auto accepts since its under the same organization.
  principal          = data.aws_caller_identity.receiver.account_id

  resource_share_arn = aws_ram_resource_share.Resource_Access_Manager.arn
}


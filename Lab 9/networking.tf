resource "aws_vpc" "VPC_A" {
  cidr_block = var.VPC_A_CIDRs["vpc"]

  tags = {
    Name = "VPC_A"
  }
}

resource "aws_subnet" "VPC_A_Public_Subnet" {
  vpc_id            = aws_vpc.VPC_A.id
  cidr_block        = var.VPC_A_CIDRs["subnet"]
  availability_zone = var.availability_zone["west-2"]

  tags = {
    Name = "VPC_A_Public_Subnet"
  }
}

resource "aws_internet_gateway" "VPC_A_GW" {
  vpc_id = aws_vpc.VPC_A.id

  tags = {
    Name = "VPC_A_GW"
  }
}

resource "aws_route_table" "VPC_A_RT" {
  vpc_id = aws_vpc.VPC_A.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_A_GW.id
  }

  route {
    cidr_block         = var.VPC_B_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_C_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_D_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_E_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_F_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_G_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  tags = {
    Name = "VPC_A_RT"
  }
}

resource "aws_route_table_association" "VPC_A_RT_Association" {
  subnet_id      = aws_subnet.VPC_A_Public_Subnet.id
  route_table_id = aws_route_table.VPC_A_RT.id
}

resource "aws_vpc" "VPC_B" {
  cidr_block = var.VPC_B_CIDRs["vpc"]

  tags = {
    "Name" = "VPC_B"
  }
}

resource "aws_subnet" "VPC_B_Public_Subnet" {
  vpc_id            = aws_vpc.VPC_B.id
  cidr_block        = var.VPC_B_CIDRs["subnet"]
  availability_zone = var.availability_zone["west-2"]

  tags = {
    Name = "VPC_B_Public_Subnet"
  }
}

resource "aws_internet_gateway" "VPC_B_GW" {
  vpc_id = aws_vpc.VPC_B.id

  tags = {
    Name = "VPC_B_GW"
  }
}

resource "aws_route_table" "VPC_B_RT" {
  vpc_id = aws_vpc.VPC_B.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_B_GW.id
  }

  route {
    cidr_block         = var.VPC_A_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_C_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_D_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_E_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_F_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_G_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  tags = {
    Name = "VPC_B_RT"
  }
}

resource "aws_route_table_association" "VPC_B_RT_Association" {
  subnet_id      = aws_subnet.VPC_B_Public_Subnet.id
  route_table_id = aws_route_table.VPC_B_RT.id
}

resource "aws_ec2_transit_gateway" "Transit_GW_A" {
  description                     = "Transit_GW_A"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  auto_accept_shared_attachments  = "enable"

  tags = {
    "Name" = "Transit_GW_A"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW_VPC_A_Attachment" {
  subnet_ids                                      = [aws_subnet.VPC_A_Public_Subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.Transit_GW_A.id
  vpc_id                                          = aws_vpc.VPC_A.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW_VPC_B_Attachment" {
  subnet_ids                                      = [aws_subnet.VPC_B_Public_Subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.Transit_GW_A.id
  vpc_id                                          = aws_vpc.VPC_B.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

# --------------------------------------------------------------------------------

resource "aws_vpc" "VPC_C" {
  cidr_block = var.VPC_C_CIDRs["vpc"]

  tags = {
    "Name" = "VPC_C"
  }
}

resource "aws_subnet" "VPC_C_Public_Subnet" {
  vpc_id            = aws_vpc.VPC_C.id
  cidr_block        = var.VPC_C_CIDRs["subnet"]
  availability_zone = var.availability_zone["west-2"]

  tags = {
    Name = "VPC_C_Public_Subnet"
  }
}

resource "aws_internet_gateway" "VPC_C_GW" {
  vpc_id = aws_vpc.VPC_C.id

  tags = {
    Name = "VPC_C_GW"
  }
}

resource "aws_route_table" "VPC_C_RT" {
  vpc_id = aws_vpc.VPC_C.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_C_GW.id
  }

  route {
    cidr_block         = var.VPC_A_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_B_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_D_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_E_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_F_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_G_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  tags = {
    Name = "VPC_C_RT"
  }
}

resource "aws_route_table_association" "VPC_C_RT_Association" {
  subnet_id      = aws_subnet.VPC_C_Public_Subnet.id
  route_table_id = aws_route_table.VPC_C_RT.id
}

resource "aws_vpc" "VPC_D" {
  cidr_block = var.VPC_D_CIDRs["vpc"]

  tags = {
    "Name" = "VPC_D"
  }
}

resource "aws_subnet" "VPC_D_Public_Subnet" {
  vpc_id            = aws_vpc.VPC_D.id
  cidr_block        = var.VPC_D_CIDRs["subnet"]
  availability_zone = var.availability_zone["west-2"]

  tags = {
    Name = "VPC_D_Public_Subnet"
  }
}

resource "aws_internet_gateway" "VPC_D_GW" {
  vpc_id = aws_vpc.VPC_D.id

  tags = {
    Name = "VPC_D_GW"
  }
}

resource "aws_route_table" "VPC_D_RT" {
  vpc_id = aws_vpc.VPC_D.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_D_GW.id
  }

  route {
    cidr_block         = var.VPC_A_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_B_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_C_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_E_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_F_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  route {
    cidr_block         = var.VPC_G_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  }

  tags = {
    Name = "VPC_D_RT"
  }
}

resource "aws_route_table_association" "VPC_D_RT_Association" {
  subnet_id      = aws_subnet.VPC_D_Public_Subnet.id
  route_table_id = aws_route_table.VPC_D_RT.id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW_VPC_C_Attachment" {
  subnet_ids                                      = [aws_subnet.VPC_C_Public_Subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.Transit_GW_A.id
  vpc_id                                          = aws_vpc.VPC_C.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW_VPC_D_Attachment" {
  subnet_ids                                      = [aws_subnet.VPC_D_Public_Subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.Transit_GW_A.id
  vpc_id                                          = aws_vpc.VPC_D.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

# ------------------------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route_table" "TGW_A_RT" {
  transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id

  tags = {
    "Name" = "TGW_A_RT"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "TGW_A_RT_Association_1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TGW_VPC_A_Attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_A_RT.id
}

resource "aws_ec2_transit_gateway_route_table_association" "TGW_A_RT_Association_2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TGW_VPC_B_Attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_A_RT.id
}

resource "aws_ec2_transit_gateway_route_table_association" "TGW_A_RT_Association_3" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TGW_VPC_C_Attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_A_RT.id
}

resource "aws_ec2_transit_gateway_route_table_association" "TGW_A_RT_Association_4" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TGW_VPC_D_Attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_A_RT.id
}

resource "aws_ec2_transit_gateway_route_table_association" "TGW_A_RT_Association_5" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.TGW_A_C_Peering_Attachment_Accept.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_A_RT.id
}

# packets destined to var.VPC_B_CIDRs["subnet"] should be sent through TGW_VPC_B_Attachment
resource "aws_ec2_transit_gateway_route" "TGW_A_Route_1" {
  destination_cidr_block         = var.VPC_A_CIDRs["subnet"]
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TGW_VPC_A_Attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_A_RT.id
}

resource "aws_ec2_transit_gateway_route" "TGW_A_Route_2" {
  destination_cidr_block         = var.VPC_B_CIDRs["subnet"]
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TGW_VPC_B_Attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_A_RT.id
}

resource "aws_ec2_transit_gateway_route" "TGW_A_Route_3" {
  destination_cidr_block         = var.VPC_C_CIDRs["subnet"]
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TGW_VPC_C_Attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_A_RT.id
}

resource "aws_ec2_transit_gateway_route" "TGW_A_Route_4" {
  destination_cidr_block         = var.VPC_D_CIDRs["subnet"]
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TGW_VPC_D_Attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_A_RT.id
}

resource "aws_ec2_transit_gateway_route" "TGW_A_Route_5" {
  destination_cidr_block         = var.VPC_E_CIDRs["subnet"]
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.TGW_A_C_Peering_Attachment_Accept.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_A_RT.id
}

resource "aws_ec2_transit_gateway_route" "TGW_A_Route_6" {
  destination_cidr_block         = var.VPC_F_CIDRs["subnet"]
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.TGW_A_C_Peering_Attachment_Accept.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_A_RT.id
}

resource "aws_ec2_transit_gateway_route" "TGW_A_Route_7" {
  destination_cidr_block         = var.VPC_G_CIDRs["subnet"]
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.TGW_A_C_Peering_Attachment_Accept.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_A_RT.id
}

# --------------------------------------------------------------------------------------------------------------------------------

resource "aws_vpc" "VPC_E" {
  provider   = aws.west-1
  cidr_block = var.VPC_E_CIDRs["vpc"]

  tags = {
    Name = "VPC_E"
  }
}

resource "aws_subnet" "VPC_E_Public_Subnet" {
  provider          = aws.west-1
  vpc_id            = aws_vpc.VPC_E.id
  cidr_block        = var.VPC_E_CIDRs["subnet"]
  availability_zone = var.availability_zone["west-1"]

  tags = {
    Name = "VPC_E_Public_Subnet"
  }
}

resource "aws_internet_gateway" "VPC_E_GW" {
  provider = aws.west-1
  vpc_id   = aws_vpc.VPC_E.id

  tags = {
    Name = "VPC_E_GW"
  }
}

resource "aws_route_table" "VPC_E_RT" {
  provider = aws.west-1
  vpc_id   = aws_vpc.VPC_E.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_E_GW.id
  }

  route {
    cidr_block         = var.VPC_A_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id
  }

  route {
    cidr_block         = var.VPC_B_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id
  }

  route {
    cidr_block         = var.VPC_C_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id
  }

  route {
    cidr_block         = var.VPC_D_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id
  }

  route {
    cidr_block         = var.VPC_F_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id
  }

  route {
    cidr_block         = var.VPC_G_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id
  }

  tags = {
    Name = "VPC_E_RT"
  }
}

resource "aws_route_table_association" "VPC_E_RT_Association" {
  provider       = aws.west-1
  subnet_id      = aws_subnet.VPC_E_Public_Subnet.id
  route_table_id = aws_route_table.VPC_E_RT.id
}

resource "aws_vpc" "VPC_F" {
  provider   = aws.west-1
  cidr_block = var.VPC_F_CIDRs["vpc"]

  tags = {
    Name = "VPC_F"
  }
}

resource "aws_subnet" "VPC_F_Public_Subnet" {
  provider          = aws.west-1
  vpc_id            = aws_vpc.VPC_F.id
  cidr_block        = var.VPC_F_CIDRs["subnet"]
  availability_zone = var.availability_zone["west-1"]

  tags = {
    Name = "VPC_F_Public_Subnet"
  }
}

resource "aws_internet_gateway" "VPC_F_GW" {
  provider = aws.west-1
  vpc_id   = aws_vpc.VPC_F.id

  tags = {
    Name = "VPC_F_GW"
  }
}

resource "aws_route_table" "VPC_F_RT" {
  provider = aws.west-1
  vpc_id   = aws_vpc.VPC_F.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_F_GW.id
  }

  route {
    cidr_block         = var.VPC_A_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id
  }

  route {
    cidr_block         = var.VPC_B_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id
  }

  route {
    cidr_block         = var.VPC_C_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id
  }

  route {
    cidr_block         = var.VPC_D_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id
  }

  route {
    cidr_block         = var.VPC_E_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id
  }

  route {
    cidr_block         = var.VPC_G_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id
  }

  tags = {
    Name = "VPC_F_RT"
  }
}

resource "aws_route_table_association" "VPC_F_RT_Association" {
  provider       = aws.west-1
  subnet_id      = aws_subnet.VPC_F_Public_Subnet.id
  route_table_id = aws_route_table.VPC_F_RT.id
}

resource "aws_vpc" "VPC_G" {
  provider   = aws.west-1
  cidr_block = var.VPC_G_CIDRs["vpc"]

  tags = {
    Name = "VPC_G"
  }
}

resource "aws_subnet" "VPC_G_Public_Subnet" {
  provider          = aws.west-1
  vpc_id            = aws_vpc.VPC_G.id
  cidr_block        = var.VPC_G_CIDRs["subnet"]
  availability_zone = var.availability_zone["west-1"]

  tags = {
    Name = "VPC_G_Public_Subnet"
  }
}

resource "aws_internet_gateway" "VPC_G_GW" {
  provider = aws.west-1
  vpc_id   = aws_vpc.VPC_G.id

  tags = {
    Name = "VPC_G_GW"
  }
}

resource "aws_route_table" "VPC_G_RT" {
  provider = aws.west-1
  vpc_id   = aws_vpc.VPC_G.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_G_GW.id
  }

  route {
    cidr_block         = var.VPC_A_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id
  }

  route {
    cidr_block         = var.VPC_B_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id
  }

  route {
    cidr_block         = var.VPC_C_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id
  }

  route {
    cidr_block         = var.VPC_D_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id
  }

  route {
    cidr_block         = var.VPC_E_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id
  }

  route {
    cidr_block         = var.VPC_F_CIDRs["subnet"]
    transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id
  }

  tags = {
    Name = "VPC_G_RT"
  }
}

resource "aws_route_table_association" "VPC_G_RT_Association" {
  provider       = aws.west-1
  subnet_id      = aws_subnet.VPC_G_Public_Subnet.id
  route_table_id = aws_route_table.VPC_G_RT.id
}

# ------------------------------------------------------------------------------------------------

# ------------------------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway" "Transit_GW_C" {
  provider                        = aws.west-1
  description                     = "Transit_GW_C"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  auto_accept_shared_attachments  = "enable"

  tags = {
    "Name" = "Transit_GW_C"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW_VPC_E_Attachment" {
  provider                                        = aws.west-1
  subnet_ids                                      = [aws_subnet.VPC_E_Public_Subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.Transit_GW_C.id
  vpc_id                                          = aws_vpc.VPC_E.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW_VPC_F_Attachment" {
  provider                                        = aws.west-1
  subnet_ids                                      = [aws_subnet.VPC_F_Public_Subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.Transit_GW_C.id
  vpc_id                                          = aws_vpc.VPC_F.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

resource "aws_ec2_transit_gateway_vpc_attachment" "TGW_VPC_G_Attachment" {
  provider                                        = aws.west-1
  subnet_ids                                      = [aws_subnet.VPC_G_Public_Subnet.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.Transit_GW_C.id
  vpc_id                                          = aws_vpc.VPC_G.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
}

resource "aws_ec2_transit_gateway_peering_attachment" "TGW_A_C_Peering_Attachment_Request" {
  # The provider attribute is added so Transit C can be applied.
  # Also Transit A creates the request, and acceptes it.
  provider = aws.west-1
  peer_account_id         = aws_ec2_transit_gateway.Transit_GW_A.owner_id
  peer_transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_A.id
  transit_gateway_id      = aws_ec2_transit_gateway.Transit_GW_C.id
  peer_region             = var.region_2

  tags = {
    Name = "TGW A and C Peering Request"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "TGW_A_C_Peering_Attachment_Accept" {
  transit_gateway_attachment_id = data.aws_ec2_transit_gateway_peering_attachment.TGW_A_C_Peering_Attachment.id

  tags = {
    Name = "TGW A and C Peering Accept"
  }
}

# ------------------------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route_table" "TGW_C_RT" {
  provider           = aws.west-1
  transit_gateway_id = aws_ec2_transit_gateway.Transit_GW_C.id

  tags = {
    "Name" = "TGW_C_RT"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "TGW_C_RT_Association_1" {
  provider                       = aws.west-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TGW_VPC_E_Attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_C_RT.id
}

resource "aws_ec2_transit_gateway_route_table_association" "TGW_C_RT_Association_2" {
  provider                       = aws.west-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TGW_VPC_F_Attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_C_RT.id
}

resource "aws_ec2_transit_gateway_route_table_association" "TGW_C_RT_Association_3" {
  provider                       = aws.west-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TGW_VPC_G_Attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_C_RT.id
}

resource "aws_ec2_transit_gateway_route_table_association" "TGW_C_RT_Association_4" {
  provider                       = aws.west-1
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.TGW_A_C_Peering_Attachment_Accept.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_C_RT.id
}

# ------------------------------------------------------------------------------------------------

# packets destined to var.VPC_B_CIDRs["subnet"] should be sent through TGW_VPC_B_Attachment
resource "aws_ec2_transit_gateway_route" "TGW_C_Route_1" {
  provider                       = aws.west-1
  destination_cidr_block         = var.VPC_A_CIDRs["subnet"]
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.TGW_A_C_Peering_Attachment_Accept.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_C_RT.id
}

resource "aws_ec2_transit_gateway_route" "TGW_C_Route_2" {
  provider                       = aws.west-1
  destination_cidr_block         = var.VPC_B_CIDRs["subnet"]
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.TGW_A_C_Peering_Attachment_Accept.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_C_RT.id
}

resource "aws_ec2_transit_gateway_route" "TGW_C_Route_3" {
  provider                       = aws.west-1
  destination_cidr_block         = var.VPC_E_CIDRs["subnet"]
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TGW_VPC_E_Attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_C_RT.id
}

resource "aws_ec2_transit_gateway_route" "TGW_C_Route_4" {
  provider                       = aws.west-1
  destination_cidr_block         = var.VPC_F_CIDRs["subnet"]
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TGW_VPC_F_Attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_C_RT.id
}

resource "aws_ec2_transit_gateway_route" "TGW_C_Route_5" {
  provider                       = aws.west-1
  destination_cidr_block         = var.VPC_G_CIDRs["subnet"]
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.TGW_VPC_G_Attachment.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.TGW_C_RT.id
}

# ------------------------------------------------------------------------------------------------

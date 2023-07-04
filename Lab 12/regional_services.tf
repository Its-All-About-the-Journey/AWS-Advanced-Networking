resource "aws_ec2_instance_connect_endpoint" "Bastion_Endpoint_VPC_A" {
  subnet_id          = aws_subnet.VPC_A_Workload_and_TGW_Subnet.id
  security_group_ids = [aws_security_group.VPC_A_SG.id]

  tags = {
    name = "Bastion_Endpoint_VPC_A"
  }
}

resource "aws_ec2_instance_connect_endpoint" "Bastion_Endpoint_VPC_B" {
  subnet_id          = aws_subnet.VPC_B_Workload_and_TGW_Subnet.id
  security_group_ids = [aws_security_group.VPC_B_SG.id]

  tags = {
    name = "Bastion_Endpoint_VPC_B"
  }
}

# ---------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway" "TGW" {
  description                     = "TGW"
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "VPC_A" {
  subnet_ids         = [aws_subnet.VPC_A_Workload_and_TGW_Subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  vpc_id             = aws_vpc.VPC_A.id
}


resource "aws_ec2_transit_gateway_vpc_attachment" "VPC_B" {
  subnet_ids         = [aws_subnet.VPC_B_Workload_and_TGW_Subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  vpc_id             = aws_vpc.VPC_B.id
}


resource "aws_ec2_transit_gateway_vpc_attachment" "Egress_VPC" {
  subnet_ids         = [aws_subnet.Egress_VPC_TGW_Subnet_1_AZ_A.id, aws_subnet.Egress_VPC_NGW_Subnet_2_AZ_B]
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
  vpc_id             = aws_vpc.Egress_VPC.id
}

# ------------------------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route_table" "RT_1" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
}

resource "aws_ec2_transit_gateway_route" "route_1" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.Egress_VPC.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.RT_1.id
}

resource "aws_ec2_transit_gateway_route" "route_2" {
  destination_cidr_block         = "10.0.0.0/8"
  blackhole                      = true
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.RT_1.id
}

resource "aws_ec2_transit_gateway_route_table_association" "RTA_1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.VPC_A.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.RT_1.id
}

resource "aws_ec2_transit_gateway_route_table_association" "RTA_2" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.VPC_B.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.RT_1.id
}

# --------------------------------------------------------------------------------------------------

resource "aws_ec2_transit_gateway_route_table" "RT_2" {
  transit_gateway_id = aws_ec2_transit_gateway.TGW.id
}

resource "aws_ec2_transit_gateway_route" "route_3" {
  destination_cidr_block         = "10.1.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.VPC_A.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.RT_2.id
}

resource "aws_ec2_transit_gateway_route" "route_4" {
  destination_cidr_block         = "10.2.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.VPC_B.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.RT_2.id
}

resource "aws_ec2_transit_gateway_route_table_association" "RTA_3" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.Egress_VPC.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.RT_2.id
}

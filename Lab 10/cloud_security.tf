resource "aws_security_group" "VPC_A_SG" {
  name        = "VPC_A_SG"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.VPC_A.id

  ingress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPC_A_SG"
  }
}

# This is the Virtual Private Gateway
resource "aws_vpn_gateway" "VPC_A_VPGW" {
  vpc_id = aws_vpc.VPC_A.id

  tags = {
    Name = "VPC_A_VPGW"
  }
}

resource "aws_vpn_gateway_attachment" "VPC_A_VPGW_Attachment" {
  vpc_id         = aws_vpc.VPC_A.id
  vpn_gateway_id = aws_vpn_gateway.VPC_A_VPGW.id
}

resource "aws_vpn_gateway_route_propagation" "VPC_A_Route_Propagation" {
  vpn_gateway_id = aws_vpn_gateway.VPC_A_VPGW.id
  route_table_id = aws_route_table.VPC_A_Public_RT.id
}

# This is the site-to-site VPN connection
resource "aws_vpn_connection" "VPN_Connection" {
  # Download CSRv AMI Config for Cisco
  customer_gateway_id = aws_customer_gateway.CGW.id
  vpn_gateway_id      = aws_vpn_gateway.VPC_A_VPGW.id
  type                = "ipsec.1"
  static_routes_only  = true

  local_ipv4_network_cidr  = aws_subnet.public_subnet_for_VPC_A_AZ_2A.cidr_block
  remote_ipv4_network_cidr = aws_subnet.public_subnet_for_VPC_B_AZ_2A.cidr_block
}

resource "aws_vpn_connection_route" "office" {
  destination_cidr_block = aws_subnet.public_subnet_for_VPC_B_AZ_2A.cidr_block
  vpn_connection_id      = aws_vpn_connection.VPN_Connection.id
}

resource "aws_ec2_transit_gateway" "SD-WAN" {
  description = "SD-WAN"
  auto_accept_shared_attachments = "enable"
  transit_gateway_cidr_blocks = [ "192.0.2.0/24"]

  tags = {
    "Name" = "SD-WAN"
  }
}

resource "aws_ec2_transit_gateway_connect" "SD-WAN_Attachment" {
  transport_attachment_id = aws_ec2_transit_gateway_vpc_attachment.Connect_VPC_Attachment.id
  transit_gateway_id      = aws_ec2_transit_gateway.SD-WAN.id
  tags = {
    "Name" = "SD-WAN_Attachment"
  }
}

resource "aws_ec2_transit_gateway_connect_peer" "SD-WAN_Connect_Peer" {
  peer_address                  = aws_network_interface.Public_Network_Interface.private_ip
  inside_cidr_blocks            = ["169.254.6.0/29"]
  # A private address can be used
  transit_gateway_address = "192.0.2.1"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.SD-WAN_Attachment.id
  bgp_asn = "64512"
  tags = {
    "Name" = "SD-WAN_Connect_Peer"
  }
}

resource "aws_ec2_transit_gateway_connect_peer" "SD-WAN_Connect_Peer_2" {
  peer_address                  = aws_network_interface.Public_Network_Interface_2.private_ip
  inside_cidr_blocks            = ["169.254.7.0/29"]
  # A private address can be used
  transit_gateway_address = "192.0.2.2"
  transit_gateway_attachment_id = aws_ec2_transit_gateway_connect.SD-WAN_Attachment.id
  bgp_asn = "64512"
  tags = {
    "Name" = "SD-WAN_Connect_Peer_2"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "Connect_VPC_Attachment" {
  subnet_ids         = [aws_subnet.public_subnet_1_for_Connect_VPC_AZ_2A.id, aws_subnet.public_subnet_2_for_Connect_VPC_AZ_2A.id]
  transit_gateway_id = aws_ec2_transit_gateway.SD-WAN.id
  vpc_id             = aws_vpc.Connect_VPC.id
  tags = {
    "Name" = "Connect_VPC_Attachment"
  }
}


resource "aws_ec2_transit_gateway_vpc_attachment" "VPC_A_Attachment" {
  subnet_ids         = [aws_subnet.private_subnet_for_VPC_A_AZ_2A.id]
  transit_gateway_id = aws_ec2_transit_gateway.SD-WAN.id
  vpc_id             = aws_vpc.VPC_A.id
  tags = {
    "Name" = "VPC_A_Attachment"
  }
}

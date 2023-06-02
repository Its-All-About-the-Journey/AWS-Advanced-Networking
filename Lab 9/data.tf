
data "aws_ec2_transit_gateway_peering_attachment" "TGW_A_C_Peering_Attachment" {
  depends_on = [aws_ec2_transit_gateway_peering_attachment.TGW_A_C_Peering_Attachment_Request]

  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway_peering_attachment.TGW_A_C_Peering_Attachment_Request.peer_transit_gateway_id]
  }

  filter {
    name = "transit-gateway-attachment-id"
    values = [  aws_ec2_transit_gateway_peering_attachment.TGW_A_C_Peering_Attachment_Request.id  ]
  }

}

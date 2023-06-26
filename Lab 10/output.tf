output "VPC_A_Private_Instance_Private_IP" {
  value = aws_instance.VPC_A_Private_Instance.private_ip
  # Tunnel source address
}

output "Connect_Peer_BGP_Address_1" {
  value = aws_ec2_transit_gateway_connect_peer.SD-WAN_Connect_Peer.peer_address
  # Tunnel interface address 1
  # 169.254.6.1/29
}

output "Connect_Peer_BGP_Address_2" {
  value = aws_ec2_transit_gateway_connect_peer.SD-WAN_Connect_Peer_2.peer_address
  # Tunnel interface address 2
  # 169.254.7.1/29
}

output "Transit_Gateway_Address_1" {
  value = aws_ec2_transit_gateway_connect_peer.SD-WAN_Connect_Peer.transit_gateway_address
  # Tunnel destination address 1
}

output "Transit_Gateway_Address_2" {
  value = aws_ec2_transit_gateway_connect_peer.SD-WAN_Connect_Peer_2.transit_gateway_address
  # Tunnel destination address 2
}

output "CSR_1_Public_IP_Address" {
  value = aws_eip_association.CSR_1_EIP_Assoc.public_ip
}

output "CSR_2_Public_IP_Address" {
  value = aws_eip_association.CSR_2_EIP_Assoc.public_ip
}

output "VPC_A_Public_Instance_Public_IP" {
  value = aws_instance.VPC_A_Public_Instance.public_ip
}

output "VPC_A_Public_Instance_Private_IP" {
  value = aws_instance.VPC_A_Public_Instance.private_ip
}

output "VPC_B_Customer_Gateway_Public_IP" {
  value = aws_eip.CGW_EIP.public_ip
}

output "VPN_Gateway_ASN" {
  value = aws_vpn_gateway.VPC_A_VPGW.amazon_side_asn
}

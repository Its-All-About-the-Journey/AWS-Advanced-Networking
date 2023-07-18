output "VPC_A_EIP" {
  description = "Elastic IP associated to the VPC_A_Subnet_A_AWS_Linux instance"
  value       = aws_eip.VPC_A_EIP.public_ip
}
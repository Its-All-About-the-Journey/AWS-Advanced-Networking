output "VPC_A_Public_Instance" {
  value = aws_instance.VPC_A_Public_Instance.public_ip
}

output "VPC_A_Private_Instance" {
  value = aws_instance.VPC_A_Private_Instance.private_ip
}

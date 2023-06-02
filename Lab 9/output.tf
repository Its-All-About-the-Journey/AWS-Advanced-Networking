output "VPC_A_Instance" {
  value = aws_instance.VPC_A_Instance.public_ip
}

output "VPC_B_Instance" {
  value = aws_instance.VPC_B_Instance.private_ip
}

output "VPC_C_Instance" {
  value = aws_instance.VPC_C_Instance.private_ip
}

output "VPC_D_Instance" {
  value = aws_instance.VPC_D_Instance.private_ip
}

output "VPC_E_Instance" {
  value    = aws_instance.VPC_E_Instance.private_ip
}

output "VPC_F_Instance" {
  value    = aws_instance.VPC_F_Instance.private_ip
}

output "VPC_G_Instance" {
  value    = aws_instance.VPC_G_Instance.private_ip
}

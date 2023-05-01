output "VPC_A_Private_Instance_Private_IP" {
  value = "ssh -i your_key.pem ec2-user@${aws_instance.VPC_A_Private_Instance.private_ip}"
}

output "VPC_B_Private_Instance_Private_IP" {
  value = "ssh -i your_key.pem ec2-user@${aws_instance.VPC_B_Private_Instance.private_ip}"
}

output "VPC_B_Private_Instance_Acct_2_Private_IP" {
  value = "ssh -i your_key.pem ec2-user@${aws_instance.VPC_A_Private_Instance_Acct_2.private_ip}"
}

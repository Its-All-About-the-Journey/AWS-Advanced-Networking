output "VPC_A_Instance" {
  value = aws_instance.VPC_A_Instance.id
}

output "VPC_B_Instance" {
  value = aws_instance.VPC_B_Instance.id
}

# SSH into instance
# aws ec2-instance-connect ssh --instance-id i-0d89ee16375601984

output "VPC_A_Instance" {
  value = aws_instance.VPC_A_Instance.id
}

output "VPC_B_Instance" {
  value = aws_instance.VPC_B_Instance.id
}

# SSH into instance using the EC2 Instance Connect Endpoint
# aws ec2-instance-connect ssh --instance-id i-06391a4188795084b

output "VPC" {
    value = data.aws_vpc.Shared_VPC_Acct_B.id
}

output "Workload" {
    value = aws_instance.Workload.id
}

# SSH into instance
# aws ec2-instance-connect ssh --instance-id i-0e094c49ff7b697cd

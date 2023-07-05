output "Workload" {
    value = aws_instance.Workload.id
}

# SSH into instance
# aws ec2-instance-connect ssh --instance-id i-xxxxx


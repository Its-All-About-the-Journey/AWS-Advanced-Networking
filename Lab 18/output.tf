output "APP" {
    value = aws_instance.APP.id
}

output "FW1_id" {
    value = aws_instance.FW1.id
}

output "FW1" {
    value = aws_instance.FW1.public_ip
}

# SSH into instance
# aws ec2-instance-connect ssh --instance-id i-05e178c03cd3c0a20

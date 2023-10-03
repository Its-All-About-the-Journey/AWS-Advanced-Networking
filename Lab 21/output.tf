output "ec2_A_ipv4" {
  value = aws_eip.one.public_ip
}

output "ec2_B_ipv4" {
  value = aws_eip.two.public_ip
}

output "ec2_C" {
  value = aws_instance.Instance_C.id
}

# SSH into instance
# ssh -i "hi.pem" ubuntu@54.185.213.20

# aws ec2-instance-connect ssh --instance-id <id>

# ping6 -n google.com

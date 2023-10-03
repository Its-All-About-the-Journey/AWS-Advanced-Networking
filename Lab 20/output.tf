output "ec2_A" {
  value = aws_instance.VPC_A[0].public_ip
}

output "ec2_B" {
  value = aws_instance.VPC_A[1].public_ip
}

output "ec2_C" {
  value = aws_instance.VPC_B.public_ip
}

# SSH into instance
# ssh -i "CharlesUneze.pem" ubuntu@34.217.191.236

# Target Instance ec2_C (start capturing)
# sudo tcpdump -i ens5 port not 22 -c 2

# Foreign Instance ec2_A 
# ping <ec2_B private IP> -c 4

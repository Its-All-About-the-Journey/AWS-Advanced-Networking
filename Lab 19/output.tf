output "Successful_TGW_Cross_Acct_Share" {
    value = data.aws_ec2_transit_gateway.Shared_TGW_Acct_B.id
}
# ssh -i "CharlesUneze.pem" ubuntu@34.217.191.236

# Reciever
# iperf -s -u -B 224.0.0.100 -i 1
output "ec2_A" {
  value = aws_instance.VPC_A.public_ip
}

# Sender
# iperf -c 224.0.0.100 -u -T 32 -t 4 -i 1

## Reciever
## iperf -s -u -B 224.0.0.251 -i 1
output "ec2_C" {
  value = aws_instance.VPC_B[1].public_ip
}

## Sender
## iperf -c 224.0.0.251 -u -T 32 -t 4 -i 1
output "ec2_D" {
  value = aws_instance.VPC_C.public_ip
}

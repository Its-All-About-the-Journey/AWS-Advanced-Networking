output "My_App_LB_DNS" {
  value = "${aws_lb.My_GWLB.dns_name}"
}

output "APP1" {
    value = aws_instance.APP1.id
}

output "APP2" {
    value = aws_instance.APP2.id
}

output "Security1" {
    value = aws_instance.Security1.public_ip
}

# SSH into instance
# aws ec2-instance-connect ssh --instance-id i-0e094c49ff7b697cd

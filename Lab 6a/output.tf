# The public IP addresses in AZ A
output "Public_Instances_1" {
  value = aws_instance.Public_Instances_Fleet_1[0].public_ip
  description = "Marketing Department"
}

output "Public_Instances_2" {
  value = aws_instance.Public_Instances_Fleet_1[1].public_ip
  description = "Sales Department"
}

# The public IP addresses in AZ B
output "Public_Instances_3" {
  value = aws_instance.Public_Instances_Fleet_2[2].public_ip
  description = "Marketing Department"
}

output "Public_Instances_4" {
  value = aws_instance.Public_Instances_Fleet_2[3].public_ip
  description = "Sales Department"
}

output "Public_Instances_1_subnet" {
  value = aws_instance.Public_Instances_Fleet_1[0].subnet_id
}

output "Public_Instances_2_subnet" {
  value = aws_instance.Public_Instances_Fleet_1[1].subnet_id
}

output "Public_Instances_3_subnet" {
  value = aws_instance.Public_Instances_Fleet_2[3].subnet_id
}

output "Public_Instances_4_subnet" {
  value = aws_instance.Public_Instances_Fleet_2[4].subnet_id
}

# DNS for Marketing and sales
output "My_App_LB_DNS_Marketing" {
  value = "${aws_lb.My_App_LB.dns_name}/marketing.html"
}

output "My_App_LB_DNS_Sales" {
  value = "${aws_lb.My_App_LB.dns_name}/sales.html"
}
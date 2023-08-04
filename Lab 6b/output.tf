# The public IP addresses in AZ A
output "Fleet_1_0" {
  value       = aws_instance.Public_Instances_Fleet_1[0].public_ip
  description = "Marketing Department"
}

output "Fleet_1_1" {
  value       = aws_instance.Public_Instances_Fleet_1[1].public_ip
  description = "Sales Department"
}

# The public IP addresses in AZ B
output "Fleet_2_0" {
  value       = aws_instance.Public_Instances_Fleet_2[0].public_ip
  description = "Marketing Department"
}

output "Fleet_2_1" {
  value       = aws_instance.Public_Instances_Fleet_2[1].public_ip
  description = "Sales Department"
}

# DNS for Marketing and sales
output "My_App_LB_DNS_Marketing" {
  value = "${aws_lb.My_Network_LB.dns_name}/marketing.html"
}

output "My_App_LB_DNS_Sales" {
  value = "${aws_lb.My_Network_LB.dns_name}/sales.html"
}

output "ENI_0" {
  value = data.aws_network_interface.ENI_0.id
}

output "ENI_1" {
  value = data.aws_network_interface.ENI_1.id
}
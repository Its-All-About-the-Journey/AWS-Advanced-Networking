# For SSH access
output "public_ip_0_Fleet_1" {
  value = data.aws_instance.Public_Instances_Fleet_1[0].public_ip
}

output "public_ip_1_Fleet_1" {
  value = data.aws_instance.Public_Instances_Fleet_1[1].public_ip
}

output "public_ip_0_Fleet_2" {
  value = data.aws_instance.Public_Instances_Fleet_2[0].public_ip
}

output "public_ip_1_Fleet_2" {
  value = data.aws_instance.Public_Instances_Fleet_2[1].public_ip
}

output "Cloudfront_Distribution_Primary" {
  value = data.aws_cloudfront_distribution.ALB_distribution.domain_name
}

output "ACM_Domain_Name" {
  value = aws_acm_certificate.cert.domain_name
}

output "My_App_LB_DNS_1a" {
  value = "${aws_lb.My_ALB[0].dns_name}/origin_1.html"
}

output "My_App_LB_DNS_1b" {
  value = "${aws_lb.My_ALB[1].dns_name}/origin_2.html"
}

output "My_ALB_DNS_2a" {
  value = "${aws_lb.My_ALB[0].dns_name}/origin_1.html"
}

output "My_ALB_DNS_2b" {
  value = "${aws_lb.My_ALB[1].dns_name}/origin_2.html"
}

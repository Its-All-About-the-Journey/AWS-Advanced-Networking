output "NLB" {
  value = "http://${aws_lb.My_Network_LB.dns_name}"
}

output "ec2" {
  value = aws_instance.Instance[0].public_ip
}

output "globalaccelerator" {
  value = "http://${aws_globalaccelerator_accelerator.accelerator.dns_name}"
}

# teraform apply -auto-approve; sleep 180 && terraform destroy auto-approve


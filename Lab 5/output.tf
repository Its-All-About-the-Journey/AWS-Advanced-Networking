output "consumer_vpc_public_instance_public_ip" {
    value = aws_instance.Consumer_VPC_Public_Instance.public_ip
}

# outputs the vpc-endpoint interface ID from the data value.
output "vpc_endpoint_service_ENI_Private_IP" {
  value = "${data.aws_network_interface.ENI_0.private_ip}"
}


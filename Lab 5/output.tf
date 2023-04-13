output "consumer_vpc_public_instance_public_ip" {
    value = aws_instance.Consumer_VPC_Public_Instance.public_ip
}

output "vpce_interface_ids" {
  value = join(",", aws_vpc_endpoint.vpce.network_interface_ids)
}

/*
# --------------------------------------------------------------
data "aws_network_interface" "ENI_0" {
  id = ""
}

output "vpc_endpoint_service_ENI_Private_IP" {
  value = "${data.aws_network_interface.ENI_0.private_ip}"
}
# --------------------------------------------------------------
*/

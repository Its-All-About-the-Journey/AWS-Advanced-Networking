output "consumer_vpc_public_instance_public_ip" {
    value = aws_instance.Consumer_VPC_Public_Instance.public_ip
}

# outputs the vpc-endpoint interface ID
output "vpce_interface_ids" {
  value = join(",", aws_vpc_endpoint.vpce.network_interface_ids)
}

# Copy the interface ID output from the CLI and uncomment the code below.
# Add the ID into the data block. Then do a 
# “terraform refresh” to get the private IP address
# of the vpc-endpoint interface so you can SSH into it from
# the public instance.
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

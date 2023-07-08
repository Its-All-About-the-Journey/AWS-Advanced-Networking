# Reads the data of the VPC Endpoint, specifically the interface ID, 

data "aws_network_interface" "ENI_0" {
  id = join(",", aws_vpc_endpoint.vpce.network_interface_ids)
}

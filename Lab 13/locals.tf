# Specifies the interface ID of the VPC endpoint as a string so 
# it can be used anywhere in the code.

locals {
  key = join(",", data.aws_vpc_endpoint.Network_Firewall_Endpoint.network_interface_ids)
}

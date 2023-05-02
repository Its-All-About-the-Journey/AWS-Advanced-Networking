# Specifies the interface ID of the VPC endpoint as a string so it can be used 
# anywhere in the code.

locals {
  key = join(",", aws_vpc_endpoint.vpce.network_interface_ids)
}

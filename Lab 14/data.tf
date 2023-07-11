data "aws_vpc_endpoint" "Network_Firewall_Endpoint_1" {
  vpc_id = aws_vpc.Egress_VPC.id

  tags = {
    Firewall                  = aws_networkfirewall_firewall.Network_Firewall_1.arn
    AWSNetworkFirewallManaged = "true"
  }
}

data "aws_vpc_endpoint" "Network_Firewall_Endpoint_2" {
  vpc_id = aws_vpc.Egress_VPC.id

  tags = {
    Firewall                  = aws_networkfirewall_firewall.Network_Firewall_2.arn
    AWSNetworkFirewallManaged = "true"
  }
}

# Reads the data of the VPC Endpoint, specifically the interface ID
data "aws_network_interface" "ENI_0" {
  id = join(",", data.aws_vpc_endpoint.Network_Firewall_Endpoint_1.network_interface_ids)
}

data "aws_network_interface" "ENI_1" {
  id = join(",", data.aws_vpc_endpoint.Network_Firewall_Endpoint_2.network_interface_ids)
}

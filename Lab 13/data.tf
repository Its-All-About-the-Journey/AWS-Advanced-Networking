data "aws_vpc_endpoint" "Network_Firewall_Endpoint" {
  vpc_id = aws_vpc.VPC.id
  #state  = "available"

  tags = {
    Firewall                  = aws_networkfirewall_firewall.Network_Firewall.arn
    AWSNetworkFirewallManaged = "true"
  }
}

# Reads the data of the VPC Endpoint, specifically the interface ID
data "aws_network_interface" "ENI_0" {
  id = local.key
}

# Calls Account B so its details are available
data "aws_caller_identity" "receiver" {
  provider = aws.Account_B
}

data "aws_vpc_endpoint" "Network_Firewall_Endpoint" {
  vpc_id = aws_vpc.Shared_VPC.id

  tags = {
    Firewall                  = aws_networkfirewall_firewall.Network_Firewall.arn
    AWSNetworkFirewallManaged = "true"
  }
}

# Verifies if the VPC is available in Account B
data "aws_vpc" "Shared_VPC_Acct_2" {
  provider = aws.Account_B
  id = aws_vpc.Shared_VPC.id
}

# Reads the data of the VPC Endpoint, specifically the interface ID
data "aws_network_interface" "ENI_0" {
  id = join(",", data.aws_vpc_endpoint.Network_Firewall_Endpoint.network_interface_ids)
}

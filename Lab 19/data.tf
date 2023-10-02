# Calls Account B so its details are available
data "aws_caller_identity" "receiver" {
  provider = aws.Account_B
}

# Verifies if the VPC is available in Account B
data "aws_ec2_transit_gateway" "Shared_TGW_Acct_B" {
  provider = aws.Account_B
  id = aws_ec2_transit_gateway.TGW.id

  depends_on = [ aws_ram_principal_association.sender_invite, aws_ram_resource_association.TGW ]
}


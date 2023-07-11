resource "aws_networkfirewall_firewall" "Network_Firewall_1" {
  name                = "Network-Firewall-1"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.Network_Firewall_Policy.arn
  vpc_id              = aws_vpc.Egress_VPC.id
  subnet_mapping {
    subnet_id = aws_subnet.Egress_VPC_Network_Firewall_Subnet_1_AZ_A.id
  }

  tags = {
    Tag1 = "Network_Firewall_1"
  }
}

resource "aws_networkfirewall_firewall" "Network_Firewall_2" {
  name                = "Network-Firewall-2"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.Network_Firewall_Policy.arn
  vpc_id              = aws_vpc.Egress_VPC.id
  subnet_mapping {
    subnet_id = aws_subnet.Egress_VPC_Network_Firewall_Subnet_2_AZ_B.id
  }

  tags = {
    Tag1 = "Network_Firewall_2"
  }
}

resource "aws_networkfirewall_firewall_policy" "Network_Firewall_Policy" {
  name = "Network-Firewall-Policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.DENY.arn
    }
  }

  tags = {
    Tag1 = "Network_Firewall_Policy"
  }
}

resource "aws_networkfirewall_rule_group" "DENY" {
  capacity = 100
  name     = "DENY"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        target_types         = ["HTTP_HOST"]
        targets              = ["www.bing.com"]
      }
    }
  }

  tags = {
    Tag1 = "DENY"
  }
}

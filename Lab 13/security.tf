resource "aws_ec2_instance_connect_endpoint" "Bastion_Endpoint_VPC" {
  subnet_id          = aws_subnet.Private_Subnet.id
  security_group_ids = [aws_security_group.VPC_SG.id]

  tags = {
    name = "Bastion_Endpoint"
  }
}

resource "aws_networkfirewall_firewall" "Network_Firewall" {
  name                = "Network-Firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.Network_Firewall_Policy.arn
  vpc_id              = aws_vpc.VPC.id
  subnet_mapping {
    subnet_id = aws_subnet.Firewall_Subnet.id
  }

  tags = {
    Tag1 = "Network_Firewall"
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

resource "aws_security_group" "VPC_SG" {
  name        = "VPC_SG"
  description = "Allow SSH and ICMP inbound traffic"
  vpc_id      = aws_vpc.VPC.id

  ingress {
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP into VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPC_SG"
  }
}

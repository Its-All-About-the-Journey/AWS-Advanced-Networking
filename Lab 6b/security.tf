resource "aws_security_group" "My_VPC_SG" {
  name        = "My_VPC_SG"
  description = "Allow SSH, HTTPS and ICMP inbound traffic"
  vpc_id      = aws_vpc.My_VPC.id

  ingress {
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS into VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP into VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "My_VPC_SG"
  }
}


/*
-------------------------------------------------------------------------------
                                    Logs
-------------------------------------------------------------------------------
*/
resource "aws_flow_log" "ENI_0" {
  iam_role_arn    = aws_iam_role.NLB_Flow_Log_Role.arn
  log_destination = aws_cloudwatch_log_group.NLB_Log_Group.arn
  traffic_type    = "ALL"
  eni_id          = data.aws_network_interface.ENI_0.id
  max_aggregation_interval = "600"
}

resource "aws_flow_log" "ENI_1" {
  iam_role_arn    = aws_iam_role.NLB_Flow_Log_Role.arn
  log_destination = aws_cloudwatch_log_group.NLB_Log_Group.arn
  traffic_type    = "ALL"
  eni_id          = data.aws_network_interface.ENI_1.id
  max_aggregation_interval = "600"
}

resource "aws_cloudwatch_log_group" "NLB_Log_Group" {
  name = "NLB_Log_Group"
  retention_in_days = "1"
  skip_destroy = false
}

resource "aws_iam_role" "NLB_Flow_Log_Role" {
  name               = "NLB-flow-log"
  assume_role_policy = data.aws_iam_policy_document.nlb_flow_log_assume_role.json
}
resource "aws_iam_role_policy" "NLB_Log_Group_Role_Policy" {
  name   = "NLB-Log-Group-Role-Policy"
  role   = aws_iam_role.NLB_Flow_Log_Role.id
  policy = data.aws_iam_policy_document.NLB_Log_Group_Policy.json
}
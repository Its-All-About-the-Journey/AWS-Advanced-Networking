data "aws_iam_policy_document" "nlb_flow_log_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "NLB_Log_Group_Policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

data "aws_network_interface" "ENI_0" {

  count = 2

  filter {
    name   = "requester-id"
    values = ["amazon-elb"]
  }

  filter {
    name   = "availability-zone"
    values = ["us-west-2a"]
  }
  
  depends_on = [ aws_lb.My_ALB ]
}

data "aws_network_interface" "ENI_1" {

  filter {
    name   = "requester-id"
    values = ["amazon-elb"]
  }

  filter {
    name   = "availability-zone"
    values = ["us-west-2b"]
  }

  depends_on = [ aws_lb.My_ALB ]
}

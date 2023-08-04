resource "aws_security_group" "My_VPC_SG" {
  name        = "My_VPC_SG"
  description = "Allow SSH, HTTP and HTTPS and ICMP inbound traffic"
  vpc_id      = aws_vpc.My_VPC.id

  ingress {
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP into VPC"
    from_port   = 80
    to_port     = 80
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
  count = 2
  iam_role_arn    = aws_iam_role.NLB_Flow_Log_Role.arn
  log_destination = aws_cloudwatch_log_group.NLB_Log_Group.arn
  traffic_type    = "ALL"
  eni_id          = data.aws_network_interface.ENI_0[count.index].id
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

/*
-------------------------------------------------------------------------------
                                    SSL
-------------------------------------------------------------------------------
*/
resource "aws_acm_certificate" "cert" {
  domain_name       = "www.charlesuneze.link"
  validation_method = "DNS"
  key_algorithm = "RSA_2048"

  tags = {
    Environment = "Terraform"
  }
}

# Cert must first be created and then its CNAME must be added to R53 before validation occurs
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.ACM : record.fqdn]

  depends_on = [aws_acm_certificate.cert, aws_route53_record.ACM]
}

/*
-------------------------------------------------------------------------------
                                    ROUTE 53
-------------------------------------------------------------------------------
*/

resource "aws_route53_record" "ACM" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name # www.charlesuneze.link
  records         = [each.value.record]
  type            = each.value.type # CNAME 
  ttl             = 60
  zone_id         = var.hosted_zone_id

}
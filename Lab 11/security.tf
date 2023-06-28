resource "aws_wafv2_ip_set" "MTN_IPv4s" {
  name               = "IP_Set"
  description        = "MTN_IPs" # signify your ISP name
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["102.88.0.0/16"] # signify your ISP CIDR assigned to you. Check "what is my IP?" on google. Use Hurricane Electric BGP Looking glass to dtermine the CIDR

  tags = {
    Tag1 = "MTN_IPs"
  }
}

resource "aws_wafv2_web_acl_association" "example" {
  resource_arn = aws_lb.My_App_LB.arn
  web_acl_arn  = aws_wafv2_web_acl.ALB.arn
}

resource "aws_wafv2_web_acl" "ALB" {
  name        = "IPv4-managed-rule"
  description = "Block request recieved from a specific MTN IPv4 CIDR block."
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    action {
        block {}
    }
    name = "Block_Req_for_MTN_IPv4s"
    priority = 1

    statement {
        ip_set_reference_statement {
            arn = aws_wafv2_ip_set.MTN_IPv4s.arn

        }
    }

    visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "blocked-IPv4s-metric"
        sampled_requests_enabled   = false
    }
  }
  
  tags = {
    Tag1 = "ALB"
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "blocked-IPv4s-metric"
    sampled_requests_enabled   = false
  }
}


resource "aws_vpc" "My_VPC" {
  cidr_block           = "192.168.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "My_VPC"
  }
}

resource "aws_internet_gateway" "My_VPC_IGW" {
  vpc_id = aws_vpc.My_VPC.id

  tags = {
    "name" = "My_VPC_IGW"
  }
}

resource "aws_subnet" "public_subnet_for_My_VPC_AZ_2A" {
  vpc_id            = aws_vpc.My_VPC.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "public_subnet_for_My_VPC_AZ_2A"
  }
}

resource "aws_subnet" "public_subnet_for_My_VPC_AZ_2B" {
  vpc_id            = aws_vpc.My_VPC.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "public_subnet_for_My_VPC_AZ_2B"
  }
}

resource "aws_security_group" "My_VPC_SG" {
  name        = "My_VPC_SG"
  description = "Allow SSH, HTTP/S and ICMP inbound traffic"
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

resource "aws_route_table" "My_VPC_RT" {
  vpc_id = aws_vpc.My_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.My_VPC_IGW.id
  }

  tags = {
    Name = "My_VPC_RT"
  }
}

resource "aws_route_table_association" "My_VPC_RT_association_AZ_2A" {
  subnet_id      = aws_subnet.public_subnet_for_My_VPC_AZ_2A.id
  route_table_id = aws_route_table.My_VPC_RT.id
}

resource "aws_route_table_association" "My_VPC_RT_association_AZ_2B" {
  subnet_id      = aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  route_table_id = aws_route_table.My_VPC_RT.id
}

# Application Loas Balancer
resource "aws_lb" "My_ALB" {
  count              = 2
  name               = "My-App-LB-${count.index}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.My_VPC_SG.id]
  subnet_mapping {
    subnet_id = aws_subnet.public_subnet_for_My_VPC_AZ_2A.id
  }
  subnet_mapping {
    subnet_id = aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  }

  enable_deletion_protection = false

  tags = {
    Environment = "production${count.index}"
  }
}

# It tells the load balancer to route the HTTP
# traffic to instances in this target group
resource "aws_lb_target_group" "HTTP" {
  count = 2
  port            = 80
  protocol        = "HTTP"
  vpc_id          = aws_vpc.My_VPC.id
  target_type     = "instance"
  ip_address_type = "ipv4"
}

# Since two instances in seperate AZs are targeted, two target group attachment is needed.
resource "aws_lb_target_group_attachment" "HTTP_1" {
  count            = 2
  target_group_arn = data.aws_lb_target_group.HTTP[count.index].arn
  target_id        = aws_instance.Public_Instances_Fleet_1[count.index].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "HTTP_2" {
  count            = 2
  target_group_arn = data.aws_lb_target_group.HTTP[count.index].arn
  target_id        = aws_instance.Public_Instances_Fleet_2[count.index].id
  port             = 80
}

# Tells the load balancer to listen for HTTP
resource "aws_lb_listener" "HTTP" {
  count             = 2
  load_balancer_arn = data.aws_lb.My_ALB[count.index].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Access Denied"
      status_code  = "403"
    }
  }
}

resource "aws_lb_listener_rule" "Only_Cloudfront_Access" {
  count        = 2
  listener_arn = data.aws_lb_listener.HTTP[count.index].arn

  action {
    type             = "forward"
    target_group_arn = data.aws_lb_target_group.HTTP[count.index].arn
  }
  
  # This is used both in Cloudfront and ALB
  condition {
    http_header {
      http_header_name = "X-Custom-Header"
      values           = ["RandomValue-1234567890"]
    }
  }
}

/*
-------------------------------------------------------------------------------
                                    SSL
-------------------------------------------------------------------------------
*/
resource "aws_acm_certificate" "cert" {
  provider          = aws.us-east-1
  domain_name       = ""
  validation_method = "DNS"

  tags = {
    Environment = "Terraform"
  }
}

# Cert must first be created and then its CNAME must be added to R53 before validation occurs
resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.us-east-1
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.ACM : record.fqdn]

  depends_on = [aws_acm_certificate.cert, aws_route53_record.ACM]
}
/*
-------------------------------------------------------------------------------
                                    Cloudfront
-------------------------------------------------------------------------------
*/
resource "aws_cloudfront_distribution" "ALB_distribution" {
  origin_group {
    origin_id = local.origin_id_map.ALB_origin_group

    failover_criteria {
      status_codes = [400, 403, 404, 416, 500, 502, 503, 504]
    }

    member {
      origin_id = local.origin_id_map.ALB_origin_id_1
    }

    member {
      origin_id = local.origin_id_map.ALB_origin_id_2
    }
  }

  origin {
    domain_name = data.aws_lb.My_ALB[0].dns_name
    origin_id   = local.origin_id_map.ALB_origin_id_1
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    }
    custom_header {
      name  = "X-Custom-Header"
      value = "RandomValue-1234567890"
    }
  }

  origin {
    domain_name = data.aws_lb.My_ALB[1].dns_name
    origin_id   = local.origin_id_map.ALB_origin_id_2
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    }
    custom_header {
      name  = "X-Custom-Header"
      value = "RandomValue-1234567890"
    }
  }

  default_cache_behavior {
    allowed_methods        = ["OPTIONS", "GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.origin_id_map.ALB_origin_group
    viewer_protocol_policy = "redirect-to-https"

    # ttl controls how long an object remains in a cache
    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "ALB Distribution"
  default_root_object = "index.html"

  provider = aws.us-east-1 # Needed because ACM is a regional resource, and it must be issued before
  # it is assigned here.
  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.cert.arn
    cloudfront_default_certificate = true
    ssl_support_method             = "sni-only"
  }

  aliases = [aws_acm_certificate.cert.domain_name]

  logging_config {
    bucket = data.aws_s3_bucket.Logs_Bucket.bucket_domain_name
    prefix = "logs/"
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "NG"]
    }
  }

  tags = {
    Environment = "Terraform"
  }

  depends_on = [aws_acm_certificate_validation.cert_validation]
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

  /*
Let's assume you have the following values for the 
aws_acm_certificate.cert.domain_validation_options attribute:

aws_acm_certificate.cert.domain_validation_options = [
  {
    domain_name              = "example.com"
    resource_record_name     = "_acme-challenge.example.com"
    resource_record_value    = "ABC123DEF456"
    resource_record_type     = "TXT"
  },
  {
    domain_name              = "subdomain.example.com"
    resource_record_name     = "_acme-challenge.subdomain.example.com"
    resource_record_value    = "XYZ789UVW321"
    resource_record_type     = "TXT"
  },
]

dvo.domain_name will take "example.com" as a key, while others will be its key and values.
"example.com" = {
  resource_record_name     = "_acme-challenge.example.com"
  resource_record_value    = "ABC123DEF456"
  resource_record_type     = "TXT"
}

They can be referenced again by using the each.value.key where the key can be a name, record or type.
*/
}

resource "aws_route53_record" "Cloudfront" {
  zone_id = var.hosted_zone_id
  name    = aws_acm_certificate.cert.domain_name
  type    = "A"

  alias {
    name                   = data.aws_cloudfront_distribution.ALB_distribution.domain_name
    zone_id                = data.aws_cloudfront_distribution.ALB_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_health_check" "Cloudfront_Health_Check" {
  fqdn              = "www.charlesuneze.link"
  port              = 443
  type              = "HTTPS"
  resource_path     = "/index.html"
  failure_threshold = "2"
  request_interval  = "10"

  tags = {
    Name = "Cloudfront_Health_Check"
  }
}



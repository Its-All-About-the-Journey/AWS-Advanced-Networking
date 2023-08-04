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

resource "aws_lb" "My_Network_LB" {
  name               = "My-Network-LB"
  internal           = false
  load_balancer_type = "network"
  subnet_mapping {
    subnet_id = aws_subnet.public_subnet_for_My_VPC_AZ_2A.id
  }
  subnet_mapping {
    subnet_id = aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  }

  enable_deletion_protection = false

  tags = {
    Name = "My_Network_LB"
  }
}

# Redirects HTTP to HTTPS
resource "aws_lb_listener" "HTTP" {
  load_balancer_arn = aws_lb.My_Network_LB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
# It tells the load balancer to route the HTTPS
# traffic to instances in this target group
resource "aws_lb_target_group" "HTTPS" {
  port            = 443
  protocol        = "TCP"
  vpc_id          = aws_vpc.My_VPC.id
  target_type     = "instance"
  ip_address_type = "ipv4"
}

# Since two instances in seperate AZs are targeted, two target group attachment is needed.
resource "aws_lb_target_group_attachment" "HTTPS_Fleet_1" {
  count            = 2
  target_group_arn = aws_lb_target_group.HTTPS.arn
  target_id        = aws_instance.Public_Instances_Fleet_1[count.index].id
  port             = 443
}

resource "aws_lb_target_group_attachment" "HTTPS_Fleet_2" {
  count            = 2
  target_group_arn = aws_lb_target_group.HTTPS.arn
  target_id        = aws_instance.Public_Instances_Fleet_2[count.index].id
  port             = 443
}

# It tells the load balancer to listen for HTTPS
resource "aws_lb_listener" "HTTPS" {
  load_balancer_arn = aws_lb.My_Network_LB.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.HTTPS.arn
  }
}

resource "aws_route53_record" "NLB" {
  zone_id = var.hosted_zone_id
  name    = ""
  type    = "A"

  alias {
    name                   = aws_lb.My_Network_LB.dns_name
    zone_id                = aws_lb.My_Network_LB.zone_id
    evaluate_target_health = true
  }
}

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

resource "aws_lb" "My_ALB" {
  name               = "My-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups = [ aws_security_group.My_VPC_SG.id ]
  subnets = [ aws_subnet.public_subnet_for_My_VPC_AZ_2A.id, aws_subnet.public_subnet_for_My_VPC_AZ_2B.id ]

  enable_deletion_protection = false

  tags = {
    Name = "My_ALB"
  }
}

# It tells the load balancer to route the HTTPS
# traffic to instances in this target group
resource "aws_lb_target_group" "HTTP" {
  port            = 80
  protocol        = "HTTP"
  vpc_id          = aws_vpc.My_VPC.id
  target_type     = "instance"
  ip_address_type = "ipv4"
}

# Since two instances in seperate AZs are targeted, two target group attachment is needed.
resource "aws_lb_target_group_attachment" "HTTP_Fleet_1" {
  count            = 2
  target_group_arn = aws_lb_target_group.HTTP.arn
  target_id        = aws_instance.Public_Instances_Fleet_1[count.index].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "HTTP_Fleet_2" {
  count            = 2
  target_group_arn = aws_lb_target_group.HTTP.arn
  target_id        = aws_instance.Public_Instances_Fleet_2[count.index].id
  port             = 80
}

# It tells the load balancer to listen for HTTP and HTTPS
resource "aws_lb_listener" "HTTP" {
  load_balancer_arn = aws_lb.My_ALB.arn
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

resource "aws_lb_listener" "HTTPS" {
  load_balancer_arn = aws_lb.My_ALB.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn = aws_acm_certificate.cert.arn
  /*
     A security policy is a combination of protocols and ciphers. 
     The protocol establishes a secure connection between a client 
     and a server and ensures that all data passed between the client 
     and your load balancer is private. A cipher is an encryption algorithm 
     that uses encryption keys to create a coded message. Protocols use several ciphers to encrypt data over the Internet.
  */
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.HTTP.arn
  }
 
}

resource "aws_route53_record" "ALB" {
  zone_id = var.hosted_zone_id
  name    = "www.charlesuneze.link"
  type    = "A"

  alias {
    name                   = aws_lb.My_ALB.dns_name
    zone_id                = aws_lb.My_ALB.zone_id
    evaluate_target_health = true
  }
}

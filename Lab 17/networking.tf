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
resource "aws_lb_target_group" "one" {
  port            = 80
  protocol        = "HTTP"
  vpc_id          = aws_vpc.My_VPC.id
  target_type     = "instance"
  ip_address_type = "ipv4"
  load_balancing_cross_zone_enabled = "true"
}

resource "aws_lb_target_group" "two" {
  port            = 80
  protocol        = "HTTP"
  vpc_id          = aws_vpc.My_VPC.id
  target_type     = "instance"
  ip_address_type = "ipv4"
  load_balancing_cross_zone_enabled = "true"
}

# Since two instances in seperate AZs are targeted, two target group attachment is needed.
resource "aws_lb_target_group_attachment" "HTTP_Fleet_1a" {
  count            = 2
  target_group_arn = aws_lb_target_group.one.arn
  target_id        = aws_instance.Public_Instances_Fleet_1a[count.index].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "HTTP_Fleet_1b" {
  count            = 2
  target_group_arn = aws_lb_target_group.one.arn
  target_id        = aws_instance.Public_Instances_Fleet_1b[count.index].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "HTTP_Fleet_2a" {
  count            = 2
  target_group_arn = aws_lb_target_group.two.arn
  target_id        = aws_instance.Public_Instances_Fleet_2a[count.index].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "HTTP_Fleet_2b" {
  count            = 2
  target_group_arn = aws_lb_target_group.two.arn
  target_id        = aws_instance.Public_Instances_Fleet_2b[count.index].id
  port             = 80
}

# It tells the load balancer to listen for HTTP
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.My_ALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"

    forward {
      target_group {
        arn = aws_lb_target_group.one.arn
        weight = 1
      }

      target_group {
        arn = aws_lb_target_group.two.arn
        weight = 1
      }

      stickiness {
        duration = "60"
        enabled = "true"
      }
    }
  }
}


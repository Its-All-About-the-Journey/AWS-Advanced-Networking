resource "aws_vpc" "VPC" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_subnet" "public_subnet_for_My_VPC_AZ_2A" {
  vpc_id            = aws_vpc.VPC.id
  availability_zone = "us-west-2a"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public_subnet_for_My_VPC_AZ_2A"
  }
}

resource "aws_subnet" "public_subnet_for_My_VPC_AZ_2B" {
  vpc_id            = aws_vpc.VPC.id
  availability_zone = "us-west-2b"
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "public_subnet_for_My_VPC_AZ_2B"
  }
}

resource "aws_route_table" "Public" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    Name = "Public"
  }
}

resource "aws_route_table_association" "Public1" {
  subnet_id      = aws_subnet.public_subnet_for_My_VPC_AZ_2A.id
  route_table_id = aws_route_table.Public.id
}

resource "aws_route_table_association" "Public2" {
  subnet_id      = aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  route_table_id = aws_route_table.Public.id
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

resource "aws_lb_listener" "HTTP" {
  load_balancer_arn = aws_lb.My_Network_LB.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.HTTP.arn
  }
}

resource "aws_lb_target_group" "HTTP" {
  port            = 80
  protocol        = "TCP"
  vpc_id          = aws_vpc.VPC.id
  target_type     = "instance"
  ip_address_type = "ipv4"
}

# Since two instances in seperate AZs are targeted, two target group attachment is needed.
resource "aws_lb_target_group_attachment" "HTTP_Fleet" {
  count            = 2
  target_group_arn = aws_lb_target_group.HTTP.arn
  target_id        = aws_instance.Instance[count.index].id
  port             = 80
}

resource "aws_globalaccelerator_accelerator" "accelerator" {
  name            = "globalaccelerator-accelerator"
  ip_address_type = "IPV4"
  enabled         = true

  tags = {
    "Name" = "Global_Accelerator"
  }
}

resource "aws_globalaccelerator_listener" "listener" {
  accelerator_arn = aws_globalaccelerator_accelerator.accelerator.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }
}

resource "aws_globalaccelerator_endpoint_group" "endpoint" {
  listener_arn = aws_globalaccelerator_listener.listener.id
  endpoint_group_region = "us-west-2"

  endpoint_configuration {
    endpoint_id = aws_lb.My_Network_LB.id
    weight      = 100
  }
}

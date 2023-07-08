resource "aws_vpc" "Provider_VPC" {
  cidr_block       = "172.16.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "Provider_VPC"
  }
}

resource "aws_subnet" "private_subnet_for_Provider_VPC_AZ_2A" {
  vpc_id            = aws_vpc.Provider_VPC.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "private_subnet_for_Provider_VPC_AZ_2A"
  }
}


resource "aws_security_group" "Provider_VPC_SG" {
  name        = "Provider_VPC_SG"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.Provider_VPC.id

  ingress {
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Provider_VPC_SG"
  }
}

resource "aws_lb" "network_load_balancer" {
  name                       = "network-lb-tf"
  internal                   = true
  load_balancer_type         = "network"
  enable_deletion_protection = false
  subnet_mapping {
    subnet_id = aws_subnet.private_subnet_for_Provider_VPC_AZ_2A.id
  }

  tags = {
    Environment = "provider"
  }
}

# It tells the load balancer to route the SSH
# traffic to an instance in this target group
resource "aws_lb_target_group" "SSH" {
  port            = 22
  protocol        = "TCP"
  vpc_id          = aws_vpc.Provider_VPC.id
  target_type     = "ip"
  ip_address_type = "ipv4"
}

resource "aws_lb_target_group_attachment" "SSH" {
  target_group_arn = aws_lb_target_group.SSH.arn
  target_id        = "172.16.1.10"
  port             = 22
}

# It tells the load balancer to listen for SSH
resource "aws_lb_listener" "SSH" {
  load_balancer_arn = aws_lb.network_load_balancer.arn
  port              = "22"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.SSH.arn
  }
}

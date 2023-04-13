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

resource "aws_subnet" "public_subnet_for_Provider_VPC_AZ_2A" {
  vpc_id            = aws_vpc.Provider_VPC.id
  cidr_block        = "172.16.2.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "public_subnet_for_Provider_VPC_AZ_2A"
  }
}

resource "aws_security_group" "Provider_VPC_SG" {
  name        = "Provider_VPC_SG"
  description = "Allow TLS, HTTP, SSH, and ICMP inbound traffic"
  vpc_id      = aws_vpc.Provider_VPC.id

  ingress {
    description = "TLS into VPC"
    from_port   = 443
    to_port     = 443
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
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
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
    Name = "Provider_VPC_SG"
  }
}

resource "aws_eip" "Provider_VPC_NAT_GW_EIP" {
  vpc      = true
}

resource "aws_nat_gateway" "Provider_VPC_NAT_GW" {
  allocation_id = aws_eip.Provider_VPC_NAT_GW_EIP.id
  subnet_id     = aws_subnet.public_subnet_for_Provider_VPC_AZ_2A.id
  connectivity_type = "public"
}

resource "aws_internet_gateway" "Provider_VPC_IGW" {
  vpc_id = aws_vpc.Provider_VPC.id

  tags = {
    Name = "Provider_VPC_IGW"
  }
}

resource "aws_route_table" "Provider_VPC_Private_RT" {
  vpc_id = aws_vpc.Provider_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Provider_VPC_NAT_GW.id
  }

  tags = {
    Name = "Provider_VPC_RT"
  }
}

resource "aws_route_table_association" "Provider_VPC_Private_RTA" {
  subnet_id      = aws_subnet.private_subnet_for_Provider_VPC_AZ_2A.id
  route_table_id = aws_route_table.Provider_VPC_Private_RT.id
}

resource "aws_route_table" "Provider_VPC_Public_RT" {
  vpc_id = aws_vpc.Provider_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Provider_VPC_IGW.id
  }

  tags = {
    Name = "Provider_VPC_Public_RT"
  }
}

resource "aws_route_table_association" "Provider_VPC_Public_RTA" {
  subnet_id      = aws_subnet.public_subnet_for_Provider_VPC_AZ_2A.id
  route_table_id = aws_route_table.Provider_VPC_Public_RT.id
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

resource "aws_lb_target_group" "HTTP" {
  port            = 80
  protocol        = "TCP"
  vpc_id          = aws_vpc.Provider_VPC.id
  target_type     = "instance"
  ip_address_type = "ipv4"
}

resource "aws_lb_target_group" "HTTPS" {
  port            = 443
  protocol        = "TCP"
  vpc_id          = aws_vpc.Provider_VPC.id
  target_type     = "instance"
  ip_address_type = "ipv4"
}

resource "aws_lb_target_group" "SSH" {
  port            = 22
  protocol        = "TCP"
  vpc_id          = aws_vpc.Provider_VPC.id
  target_type     = "instance"
  ip_address_type = "ipv4"
}

resource "aws_lb_target_group_attachment" "HTTP" {
  target_group_arn = aws_lb_target_group.HTTP.arn
  target_id        = aws_instance.Provider_VPC_Private_Instance.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "HTTPS" {
  target_group_arn = aws_lb_target_group.HTTPS.arn
  target_id        = aws_instance.Provider_VPC_Private_Instance.id
  port             = 443
}

resource "aws_lb_target_group_attachment" "SSH" {
  target_group_arn = aws_lb_target_group.SSH.arn
  target_id        = aws_instance.Provider_VPC_Private_Instance.id
  port             = 22
}

resource "aws_lb_listener" "HTTP" {
  load_balancer_arn = aws_lb.network_load_balancer.arn
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.HTTP.arn
  }
}

resource "aws_lb_listener" "SSH" {
  load_balancer_arn = aws_lb.network_load_balancer.arn
  port              = "22"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.SSH.arn
  }
}

resource "aws_lb_listener" "HTTPS" {
  load_balancer_arn = aws_lb.network_load_balancer.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.HTTPS.arn
  }
}

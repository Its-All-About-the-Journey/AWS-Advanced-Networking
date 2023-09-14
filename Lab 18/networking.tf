#########################################################################
#                             WORKLOAD                                  #
#########################################################################
resource "aws_vpc" "Workload_VPC" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Workload_VPC"
  }
}

resource "aws_internet_gateway" "Workload_VPC_IGW" {
  vpc_id = aws_vpc.Workload_VPC.id

  tags = {
    "name" = "Workload_VPC_IGW"
  }
}

resource "aws_subnet" "GWLBE1_AZ_2A" {
  vpc_id            = aws_vpc.Workload_VPC.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "GWLBE1_AZ_2A"
  }
}

resource "aws_subnet" "GWLBE2_AZ_2B" {
  vpc_id            = aws_vpc.Workload_VPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "GWLBE2_AZ_2B"
  }
}

resource "aws_subnet" "APP1_AZ_2A" {
  vpc_id            = aws_vpc.Workload_VPC.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "APP1_AZ_2A"
  }
}

resource "aws_subnet" "APP2_AZ_2B" {
  vpc_id            = aws_vpc.Workload_VPC.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "APP2_AZ_2B"
  }
}

resource "aws_vpc_endpoint_service" "GWLBE-Service" {
  acceptance_required        = false
  allowed_principals         = [data.aws_caller_identity.current.arn]
  # Attach GWLB in the Security VPC
  gateway_load_balancer_arns = [aws_lb.My_GWLB.arn]
}

resource "aws_vpc_endpoint" "GWLBE" {
  service_name      = aws_vpc_endpoint_service.GWLBE-Service.service_name
  subnet_ids        = [aws_subnet.GWLBE1_AZ_2A.id, aws_subnet.GWLBE2_AZ_2B.id]
  vpc_endpoint_type = aws_vpc_endpoint_service.GWLBE-Service.service_type
  vpc_id            = aws_vpc.Workload_VPC.id
}

resource "aws_route_table" "IGW_RT" {
  vpc_id = aws_vpc.Workload_VPC.id

  route {
    cidr_block = aws_subnet.GWLBE1_AZ_2A.cidr_block
    vpc_endpoint_id = aws_vpc_endpoint.GWLBE.id
  }

  route {
    cidr_block = aws_subnet.GWLBE2_AZ_2B.cidr_block
    vpc_endpoint_id = aws_vpc_endpoint.GWLBE.id
  }

  tags = {
    Name = "GWLBE_RT"
  }
}

resource "aws_route_table_association" "IGW" {
  gateway_id     = aws_internet_gateway.Workload_VPC_IGW.id
  route_table_id = aws_route_table.IGW_RT.id
}

resource "aws_route_table" "GWLBE_RT" {
  vpc_id = aws_vpc.Workload_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Workload_VPC_IGW.id
  }

  tags = {
    Name = "GWLBE_RT"
  }
}

resource "aws_route_table_association" "GWLBE_RTA_AZ_2A" {
  subnet_id      = aws_subnet.GWLBE1_AZ_2A.id
  route_table_id = aws_route_table.GWLBE_RT.id
}

resource "aws_route_table_association" "GWLBE_RTA_AZ_2B" {
  subnet_id      = aws_subnet.GWLBE2_AZ_2B.id
  route_table_id = aws_route_table.GWLBE_RT.id
}

resource "aws_route_table" "APP_RT" {
  vpc_id = aws_vpc.Workload_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = aws_vpc_endpoint.GWLBE.id
  }

  route {
    cidr_block = "0.0.0.0/0"
    vpc_endpoint_id = aws_vpc_endpoint.GWLBE.id
  }

  tags = {
    Name = "APP_RT"
  }
}

resource "aws_route_table_association" "APP_RTA_AZ_2A" {
  subnet_id      = aws_subnet.APP1_AZ_2A.id
  route_table_id = aws_route_table.GWLBE_RT.id
}

resource "aws_route_table_association" "APP_RTA_AZ_2B" {
  subnet_id      = aws_subnet.APP2_AZ_2B.id
  route_table_id = aws_route_table.GWLBE_RT.id
}

#########################################################################
#                             SECURITY                                  #
#########################################################################
resource "aws_vpc" "Security_VPC" {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Security_VPC"
  }
}

resource "aws_subnet" "GWLB_AZ_2A" {
  vpc_id            = aws_vpc.Security_VPC.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "GWLB_AZ_2A"
  }
}

resource "aws_subnet" "GWLB_AZ_2B" {
  vpc_id            = aws_vpc.Security_VPC.id
  cidr_block        = "10.1.2.0/24"
  availability_zone = "us-west-2b"

  tags = {
    Name = "GWLB_AZ_2B"
  }
}

resource "aws_launch_template" "LT" {
  name_prefix   = "LaunchTemplate"
  image_id      = "ami-0eb3cf4f68aef5893"
  instance_type = "t3.small"
}

resource "aws_autoscaling_group" "ASG" {
  availability_zones = ["us-west-2a", "us-west-2b"]
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1

  launch_template {
    id      = aws_launch_template.LT.id
    version = "$Latest"
  }
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "ASG-attachment" {
  autoscaling_group_name = aws_autoscaling_group.ASG.id
  lb_target_group_arn    = aws_lb_target_group.FW.arn
}

resource "aws_lb" "My_GWLB" {
  name               = "My-GWLB"
  internal           = false
  load_balancer_type = "gateway"
  subnets = [ aws_subnet.GWLB_AZ_2A.id, aws_subnet.GWLB_AZ_2B.id ]

  enable_deletion_protection = false

  tags = {
    Name = "My_GWLB"
  }
}

# It tells the load balancer to route the HTTPS
# traffic to instances in this target group
resource "aws_lb_target_group" "FW" {
  port            = 6081
  protocol        = "GENEVE"
  vpc_id          = aws_vpc.Security_VPC.id
  target_type     = "instance"
  ip_address_type = "ipv4"
}

# Two instances in separate AZs are targeted, so two target group attachments are needed.
resource "aws_lb_target_group_attachment" "FWA1" {
  count            = 2
  target_group_arn = aws_lb_target_group.FW.arn
  target_id        = aws_instance.Security1.id
}

resource "aws_lb_target_group_attachment" "FWA2" {
  count            = 2
  target_group_arn = aws_lb_target_group.FW.arn
  target_id        = aws_instance.Security2.id
}

# It tells the load balancer to listen for all protocols and ports
resource "aws_lb_listener" "GWLB" {
  load_balancer_arn = aws_lb.My_GWLB.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.FW.arn
  }
}


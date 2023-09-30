resource "aws_network_interface" "Management_Interface1" {
  subnet_id = aws_subnet.Management_Traffic_Subnet_1.id
  private_ips = [ "10.1.3.10" ]
  source_dest_check = false
  security_groups = [ aws_security_group.Security_VPC_SG.id ]

  tags = {
    "Name" = "Management_Interface1"
  }
}

resource "aws_network_interface" "Data_Interface1" {
  subnet_id = aws_subnet.Data_Traffic_Subnet_1.id
  private_ips = [ "10.1.1.20" ]
  source_dest_check = false
  security_groups = [ aws_security_group.Security_VPC_SG.id ]

  tags = {
    "Name" = "Data_Interface1"
  }
}

resource "aws_instance" "FW1" {
  ami = "ami-0eb3cf4f68aef5893"
  instance_type = "t3.small"

  network_interface {
    network_interface_id = aws_network_interface.Management_Interface1.id
    device_index = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.Data_Interface1.id
    device_index = 1
  }

  tags = {
    "Name" = "FW1"
  }
}

resource "aws_network_interface" "Management_Interface2" {
  subnet_id = aws_subnet.Management_Traffic_Subnet_2.id
  private_ips = [ "10.1.4.10" ]
  source_dest_check = false
  security_groups = [ aws_security_group.Security_VPC_SG.id ]

  tags = {
    "Name" = "Management_Interface2"
  }
}

resource "aws_network_interface" "Data_Interface2" {
  subnet_id = aws_subnet.Data_Traffic_Subnet_2.id
  private_ips = [ "10.1.2.20" ]
  source_dest_check = false
  security_groups = [ aws_security_group.Security_VPC_SG.id ]

  tags = {
    "Name" = "Data_Interface2"
  }
}

resource "aws_instance" "FW2" {
  ami = "ami-0eb3cf4f68aef5893"
  instance_type = "t3.small"

  network_interface {
    network_interface_id = aws_network_interface.Management_Interface2.id
    device_index = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.Data_Interface2.id
    device_index = 1
  }

  tags = {
    "Name" = "FW2"
  }
}

resource "aws_lb" "My_GWLB" {
  name               = "My-GWLB"
  internal           = false
  load_balancer_type = "gateway"
  subnets = [ aws_subnet.Data_Traffic_Subnet_1.id, aws_subnet.Data_Traffic_Subnet_2.id ]

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
  target_id        = aws_instance.FW1.id
}

resource "aws_lb_target_group_attachment" "FWA2" {
  count            = 2
  target_group_arn = aws_lb_target_group.FW.arn
  target_id        = aws_instance.FW2.id
}

# It tells the load balancer to listen for all protocols and ports
resource "aws_lb_listener" "GWLB" {
  load_balancer_arn = aws_lb.My_GWLB.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.FW.arn
  }
}

########################################################################################

resource "aws_instance" "APP" {
  ami           = "ami-0b029b1931b347543" # Amazon Linux
  instance_type = "t2.micro"
  tenancy       = "default"

  subnet_id                   = aws_subnet.Private.id
  security_groups             = [aws_security_group.Workload_VPC_SG.id]
 
  tags = {
    Name = "APP"
  }
}

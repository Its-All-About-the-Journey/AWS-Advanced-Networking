resource "aws_instance" "Public_Instances_Fleet_1" {
  count                       = 2
  ami                         = "ami-0b029b1931b347543"
  instance_type               = "t2.micro"
  tenancy                     = "default"
  key_name                    = ""
  
  # 1/2=0.5 odd, 2/2=1 even
  # if count.index is divided by 2 and the remainder is even, 
  # assign instance to aws_subnet.public_subnet_for_My_VPC_AZ_2A.id, 
  # else aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  subnet_id                   = count.index % 2 == 0 ? aws_subnet.public_subnet_for_My_VPC_AZ_2A.id : aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  security_groups             = ["${aws_security_group.My_VPC_SG.id}"]
  associate_public_ip_address = true
  user_data = <<-EOF
    #!/bin/bash
    sudo su
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl start httpd
    sudo systemctl enable httpd
    sudo chmod 777 /var/www/html
    cd /var/www/html
    echo "<!DOCTYPE html><html><head><title>Sales Department</title></head><body><h1>Sales Department</h1><p>This is the sales department web page.</p></body></html>" > sales.html
  EOF

  tags = {
    Name = "Instance ${count.index + 1}"
  }
}

resource "aws_instance" "Public_Instances_Fleet_2" {
  count                       = 2
  ami                         = "ami-0b029b1931b347543"
  instance_type               = "t2.micro"
  tenancy                     = "default"
  key_name                    = ""

  # 1/2=0.5 odd, 2/2=1 even
  # if count.index is divided by 2 and the remainder is even, 
  # assign instance to aws_subnet.public_subnet_for_My_VPC_AZ_2A.id, 
  # else aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  subnet_id                   = count.index % 2 == 0 ? aws_subnet.public_subnet_for_My_VPC_AZ_2A.id : aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  security_groups             = ["${aws_security_group.My_VPC_SG.id}"]
  associate_public_ip_address = true
  user_data = <<-EOF
    #!/bin/bash
    sudo su
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl start httpd
    sudo systemctl enable httpd
    sudo chmod 777 /var/www/html
    cd /var/www/html
    echo "<!DOCTYPE html><html><head><title>Marketing Department</title></head><body><h1>Marketing Department</h1><p>This is the marketing department web page.</p></body></html>" > marketing.html
  EOF

  tags = {
    Name = "Instance ${count.index + 1}"
  }
}

resource "aws_lb" "My_App_LB" {
  name               = "My-App-LB"
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
    Environment = "production"
  }
}

# It tells the load balancer to route the HTTP
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
  count = 2
  target_group_arn = aws_lb_target_group.HTTP.arn
  target_id        = aws_instance.Public_Instances_Fleet_1[count.index].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "HTTP_Fleet_2" {
  count = 2
  target_group_arn = aws_lb_target_group.HTTP.arn
  target_id        = aws_instance.Public_Instances_Fleet_2[count.index].id
  port             = 80
}

# It tells the load balancer to listen for HTTP
resource "aws_lb_listener" "HTTP" {
  load_balancer_arn = aws_lb.My_App_LB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.HTTP.arn
  }
}

resource "aws_instance" "Public_Instances_Fleet_1" {
  # creates 2 instances
  count                       = 2
  ami                         = "ami-0b029b1931b347543"
  instance_type               = "t2.micro"
  tenancy                     = "default"
  key_name                    = ""
  
  # 1/2=0.5 remainder 5, so odd, 2/2=1 remainder is 0, so even.
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
  # creates 2 instances
  count                       = 2
  ami                         = "ami-0b029b1931b347543"
  instance_type               = "t2.micro"
  tenancy                     = "default"
  key_name                    = ""

   # 1/2=0.5 remainder 5, so odd, 2/2=1 remainder is 0, so even.
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

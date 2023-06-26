resource "aws_network_interface" "Private_Network_Interface_VPC_A" {
  subnet_id         = aws_subnet.private_subnet_for_VPC_A_AZ_2A.id
  security_groups   = ["${aws_security_group.VPC_A_SG.id}"]
  source_dest_check = true
  private_ips       = ["10.0.1.10"]

  tags = {
    Name = "Private_Network_Interface_VPC_A"
  }
}

resource "aws_instance" "VPC_A_Private_Instance" {
  ami               = "ami-0b029b1931b347543"
  instance_type     = "t2.micro"
  tenancy           = "default"
  availability_zone = "us-west-2a"
  key_name          = ""

  network_interface {
    network_interface_id = aws_network_interface.Private_Network_Interface_VPC_A.id
    device_index         = 0
  }

  tags = {
    "name" = "VPC_A_Private_Instance"
  }
}

resource "aws_network_interface" "Primary_Network_Interface" {
  provider          = aws.us-west-1
  subnet_id         = aws_subnet.public_subnet_for_VPC_B_AZ_2A.id
  security_groups   = ["${aws_security_group.VPC_B_SG.id}"]
  source_dest_check = false
  private_ips       = ["10.1.1.10"]

  tags = {
    Name = "Primary_Network_Interface"
  }
}

resource "aws_instance" "VPC_B_Customer_Gateway" {
  provider          = aws.us-west-1
  #ami               = "ami-0b1bbb7a344922144" # CSR 1000V us-west-2
  ami = "ami-01df4015e21b3f764" # CSR 1000v us-west-1
  instance_type     = "t3.medium"
  tenancy           = "default"
  availability_zone = "us-west-1a"
  key_name          = ""

  network_interface {
    network_interface_id = aws_network_interface.Primary_Network_Interface.id
    device_index         = 0
  }

  tags = {
    "name" = "VPC_B_Customer_Gateway"
  }
}

resource "aws_network_interface" "Public_Network_Interface" {
  subnet_id         = aws_subnet.public_subnet_1_for_Connect_VPC_AZ_2A.id
  security_groups   = ["${aws_security_group.CSR_SG.id}"]
  source_dest_check = false
  private_ips       = ["172.31.0.10"]

  tags = {
    Name = "Public_Network_Interface"
  }

}

resource "aws_instance" "CSR_1" {
  ami = "ami-0a26a933729195b66" # CSR 1000V us-west-2
  instance_type     = "t2.medium"
  tenancy           = "default"
  availability_zone = "us-west-2a"
  key_name          = ""

  network_interface {
    network_interface_id = aws_network_interface.Public_Network_Interface.id
    device_index         = 0
  }

  tags = {
    "name" = "CSR_1"
  }
}

resource "aws_network_interface" "Public_Network_Interface_2" {
  subnet_id         = aws_subnet.public_subnet_2_for_Connect_VPC_AZ_2A.id
  security_groups   = ["${aws_security_group.CSR_SG.id}"]
  source_dest_check = false
  private_ips       = ["172.31.1.10"]

  tags = {
    Name = "Public_Network_Interface_2"
  }

}

resource "aws_instance" "CSR_2" {
  ami = "ami-0a26a933729195b66" # CSR 1000V us-west-2
  instance_type     = "t2.medium"
  tenancy           = "default"
  availability_zone = "us-west-2b"
  key_name          = ""

  network_interface {
    network_interface_id = aws_network_interface.Public_Network_Interface_2.id
    device_index         = 0
  }

  tags = {
    "name" = "CSR_2"
  }
}

resource "aws_network_interface" "Provider_VPC_Private_Instance" {
  private_ips     = ["172.16.1.10"]
  subnet_id       = aws_subnet.private_subnet_for_Provider_VPC_AZ_2A.id
  security_groups = ["${aws_security_group.Provider_VPC_SG.id}"]

  tags = {
    name = "Provider_VPC_Private_Instance"
  }
}

resource "aws_instance" "Provider_VPC_Private_Instance" {
  ami               = "ami-0b029b1931b347543"
  instance_type     = "t2.micro"
  tenancy           = "default"
  availability_zone = "us-west-2a"
  key_name          = ""

  network_interface {
    network_interface_id = aws_network_interface.Provider_VPC_Private_Instance.id
    device_index         = 0
  }


  tags = {
    "name" = "Provider_VPC_Private_Instance"
  }
}

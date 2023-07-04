resource "aws_network_interface" "VPC_A" {
  subnet_id       = aws_subnet.VPC_A_Workload_and_TGW_Subnet.id
  private_ips     = ["10.1.1.10"]
  security_groups = [aws_security_group.VPC_A_SG.id]

  tags = {
    name = "VPC_A"
  }
}

resource "aws_instance" "VPC_A_Instance" {
  ami               = "ami-0b029b1931b347543"
  instance_type     = "t2.micro"
  tenancy           = "default"
  key_name          = ""

  network_interface {
    network_interface_id = aws_network_interface.VPC_A.id
    device_index         = 0
  }

  tags = {
    name = "VPC_A_Instance"
  }
}

resource "aws_network_interface" "VPC_B" {
  subnet_id       = aws_subnet.VPC_B_Workload_and_TGW_Subnet.id
  private_ips     = ["10.2.1.10"]
  security_groups = [aws_security_group.VPC_B_SG.id]
  key_name          = ""

  tags = {
    name = "VPC_B"
  }
}

resource "aws_instance" "VPC_B_Instance" {
  ami               = "ami-0b029b1931b347543"
  instance_type     = "t2.micro"
  tenancy           = "default"

  network_interface {
    network_interface_id = aws_network_interface.VPC_B.id
    device_index         = 0
  }

  tags = {
    name = "VPC_B_Instance"
  }
}

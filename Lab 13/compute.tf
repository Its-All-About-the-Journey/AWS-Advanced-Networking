resource "aws_network_interface" "VPC" {
  subnet_id       = aws_subnet.Private_Subnet.id
  private_ips     = ["10.0.3.10"]
  security_groups = [aws_security_group.VPC_SG.id]

  tags = {
    name = "VPC"
  }
}

resource "aws_instance" "Workload" {
  ami           = "ami-0b029b1931b347543"
  instance_type = "t2.micro"
  tenancy       = "default"

  network_interface {
    network_interface_id = aws_network_interface.VPC.id
    device_index         = 0
  }

  tags = {
    name = "Workload"
  }
}

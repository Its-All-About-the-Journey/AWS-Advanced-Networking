resource "aws_network_interface" "Workload" {
  subnet_id       = aws_subnet.Private_Subnet_Acct_B.id
  private_ips     = ["10.1.3.10"]
  security_groups = [aws_security_group.VPC_SG.id]

  tags = {
    name = "Workload"
  }
}

resource "aws_instance" "Workload" {
  ami           = "ami-0b029b1931b347543"
  instance_type = "t2.micro"
  tenancy       = "default"

  network_interface {
    network_interface_id = aws_network_interface.Workload.id
    device_index         = 0
  }

  tags = {
    name = "Workload"
  }
}

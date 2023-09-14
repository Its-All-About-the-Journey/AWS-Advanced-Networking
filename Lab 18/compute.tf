resource "aws_instance" "Security1" {
  ami           = "ami-0eb3cf4f68aef5893" # Fortinet FortiGate (BYOL) NGFW
  instance_type = "t3.small"
  tenancy       = "default"

  subnet_id                   = aws_subnet.GWLB_AZ_2A.id
  security_groups             = [aws_security_group.Security_VPC_SG.id]
  associate_public_ip_address = true

  tags = {
    Name = "FW1"
  }
}

resource "aws_instance" "Security2" {
  ami           = "ami-0eb3cf4f68aef5893" # Fortinet FortiGate (BYOL) NGFW
  instance_type = "t3.small"
  tenancy       = "default"

  subnet_id                   = aws_subnet.GWLB_AZ_2B.id
  security_groups             = [aws_security_group.Security_VPC_SG.id]
  associate_public_ip_address = true

  tags = {
    Name = "FW2"
  }
}

resource "aws_instance" "APP1" {
  ami           = "ami-0b029b1931b347543" # Amazon Linux
  instance_type = "t2.micro"
  tenancy       = "default"

  subnet_id                   = aws_subnet.APP1_AZ_2A.id
  security_groups             = [aws_security_group.Workload_VPC_SG.id]
  associate_public_ip_address = true

  tags = {
    Name = "APP1"
  }
}

resource "aws_instance" "APP2" {
  ami           = "ami-0b029b1931b347543" # Amazon Linux
  instance_type = "t2.micro"
  tenancy       = "default"

  subnet_id                   = aws_subnet.APP2_AZ_2B.id
  security_groups             = [aws_security_group.Workload_VPC_SG.id]
  associate_public_ip_address = true

  tags = {
    Name = "APP2"
  }
}

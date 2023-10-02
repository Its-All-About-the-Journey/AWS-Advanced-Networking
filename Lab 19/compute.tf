resource "aws_instance" "VPC_A" {
  ami               = "ami-03f65b8614a860c29" # Ubuntu
  instance_type     = "t3.micro" # Nitro based instance
  availability_zone = "us-west-2a"
  tenancy           = "default"
  subnet_id         = aws_subnet.Public_A.id
  security_groups   = [aws_security_group.SG_A.id]
  associate_public_ip_address = true
  key_name = ""

  tags = {
    "Name" = "Instance 1"
  }
}

resource "aws_instance" "VPC_B" {
  count             = 2
  ami               = "ami-03f65b8614a860c29"
  instance_type     = "t3.micro"
  availability_zone = "us-west-2a"
  tenancy           = "default"
  subnet_id         = aws_subnet.Public_B.id
  security_groups   = [aws_security_group.SG_B.id]
  associate_public_ip_address = true
  key_name = ""

  tags = {
    "Name" = "Instance ${element(["2", "3"], count.index)}"
  }
}

resource "aws_instance" "VPC_C" {
  provider = aws.Account_B
  ami               = "ami-03f65b8614a860c29"
  instance_type     = "t3.micro"
  availability_zone = "us-west-2a"
  tenancy           = "default"
  subnet_id         = aws_subnet.Public_C.id
  security_groups   = [aws_security_group.SG_C.id]
  associate_public_ip_address = true
  key_name = ""

  tags = {
    "Name" = "Instance 4"
  }
}

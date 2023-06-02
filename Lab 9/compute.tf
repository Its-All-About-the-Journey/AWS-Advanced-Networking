resource "aws_instance" "VPC_A_Instance" {
  ami                         = "ami-04e914639d0cca79a"
  instance_type               = "t2.micro"
  tenancy                     = "default"
  key_name                    = ""
  subnet_id                   = aws_subnet.VPC_A_Public_Subnet.id
  security_groups             = [aws_security_group.VPC_A_SG.id]
  associate_public_ip_address = true

  tags = {
    Name = "VPC_A_Instance"
  }
}

resource "aws_instance" "VPC_B_Instance" {
  ami                         = "ami-04e914639d0cca79a"
  instance_type               = "t2.micro"
  tenancy                     = "default"
  key_name                    = ""
  subnet_id                   = aws_subnet.VPC_B_Public_Subnet.id
  security_groups             = [aws_security_group.VPC_B_SG.id]
  associate_public_ip_address = true

  tags = {
    Name = "VPC_B_Instance"
  }
}

resource "aws_instance" "VPC_C_Instance" {
  ami                         = "ami-04e914639d0cca79a"
  instance_type               = "t2.micro"
  tenancy                     = "default"
  key_name                    = ""
  subnet_id                   = aws_subnet.VPC_C_Public_Subnet.id
  security_groups             = [aws_security_group.VPC_C_SG.id]
  associate_public_ip_address = true

  tags = {
    Name = "VPC_C_Instance"
  }
}

resource "aws_instance" "VPC_D_Instance" {
  ami                         = "ami-04e914639d0cca79a"
  instance_type               = "t2.micro"
  tenancy                     = "default"
  key_name                    = ""
  subnet_id                   = aws_subnet.VPC_D_Public_Subnet.id
  security_groups             = [aws_security_group.VPC_D_SG.id]
  associate_public_ip_address = true

  tags = {
    Name = "VPC_D_Instance"
  }
}

resource "aws_instance" "VPC_E_Instance" {
  provider                    = aws.west-1
  ami                         = "ami-0062dbf6b829f04e1"
  instance_type               = "t2.micro"
  tenancy                     = "default"
  key_name                    = ""
  subnet_id                   = aws_subnet.VPC_E_Public_Subnet.id
  security_groups             = [ aws_security_group.VPC_E_SG.id ]
  associate_public_ip_address = true

  tags = {
    Name = "VPC_E_Instance"
  }
}

resource "aws_instance" "VPC_F_Instance" {
  provider                    = aws.west-1
  ami                         = "ami-0062dbf6b829f04e1"
  instance_type               = "t2.micro"
  tenancy                     = "default"
  key_name                    = ""
  subnet_id                   = aws_subnet.VPC_F_Public_Subnet.id
  security_groups             = [ aws_security_group.VPC_F_SG.id ]
  associate_public_ip_address = true

  tags = {
    Name = "VPC_F_Instance"
  }
}

resource "aws_instance" "VPC_G_Instance" {
  provider                    = aws.west-1
  ami                         = "ami-0062dbf6b829f04e1"
  instance_type               = "t2.micro"
  tenancy                     = "default"
  key_name                    = ""
  subnet_id                   = aws_subnet.VPC_G_Public_Subnet.id
  security_groups             = [ aws_security_group.VPC_G_SG.id ]
  associate_public_ip_address = true

  tags = {
    Name = "VPC_G_Instance"
  }
}

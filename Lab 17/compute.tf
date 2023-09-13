resource "aws_instance" "Public_Instances_Fleet_1a" {
  count         = 2
  ami           = "ami-0507f77897697c4ba"
  instance_type = "t2.micro"
  tenancy       = "default"

  subnet_id                   = aws_subnet.public_subnet_for_My_VPC_AZ_2A.id
  security_groups             = ["${aws_security_group.My_VPC_SG.id}"]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/marketing_a.sh")

  tags = {
    Name = "Fleet_1a [${count.index + 1}]"
  }
}

resource "aws_instance" "Public_Instances_Fleet_1b" {
  count         = 2
  ami           = "ami-0507f77897697c4ba"
  instance_type = "t2.micro"
  tenancy       = "default"

  subnet_id                   = aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  security_groups             = ["${aws_security_group.My_VPC_SG.id}"]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/marketing_b.sh")

  tags = {
    Name = "Fleet_1b [${count.index + 1}]"
  }
}

resource "aws_instance" "Public_Instances_Fleet_2a" {
  count         = 2
  ami           = "ami-0507f77897697c4ba"
  instance_type = "t2.micro"
  tenancy       = "default"

  subnet_id                   = aws_subnet.public_subnet_for_My_VPC_AZ_2A.id
  security_groups             = ["${aws_security_group.My_VPC_SG.id}"]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/sales_a.sh")

  tags = {
    Name = "Fleet_2a [${count.index + 1}]"
  }
}

resource "aws_instance" "Public_Instances_Fleet_2b" {
  count         = 2
  ami           = "ami-0507f77897697c4ba"
  instance_type = "t2.micro"
  tenancy       = "default"

  subnet_id                   = aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  security_groups             = ["${aws_security_group.My_VPC_SG.id}"]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/sales_b.sh")

  tags = {
    Name = "Fleet_2b [${count.index + 1}]"
  }
}

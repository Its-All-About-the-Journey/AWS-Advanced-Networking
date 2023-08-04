resource "aws_instance" "Public_Instances_Fleet_1" {
  count         = 2
  ami           = "ami-0507f77897697c4ba"
  instance_type = "t2.micro"
  tenancy       = "default"
  key_name      = ""

  # 1/2=0.5 odd, 2/2=1 even
  # if count.index is divided by 2 and the remainder is even, 
  # assign instance to aws_subnet.public_subnet_for_My_VPC_AZ_2A.id, 
  # else aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  subnet_id                   = count.index % 2 == 0 ? aws_subnet.public_subnet_for_My_VPC_AZ_2A.id : aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  security_groups             = ["${aws_security_group.My_VPC_SG.id}"]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/marketing.sh")

  tags = {
    Name = "Fleet_1 [${count.index + 1}]"
  }
}

resource "aws_instance" "Public_Instances_Fleet_2" {
  count         = 2
  ami           = "ami-0507f77897697c4ba"
  instance_type = "t2.micro"
  tenancy       = "default"
  key_name      = ""

  # 1/2=0.5 odd, 2/2=1 even
  # if count.index is divided by 2 and the remainder is even, 
  # assign instance to aws_subnet.public_subnet_for_My_VPC_AZ_2A.id, 
  # else aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  subnet_id                   = count.index % 2 == 0 ? aws_subnet.public_subnet_for_My_VPC_AZ_2A.id : aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  security_groups             = ["${aws_security_group.My_VPC_SG.id}"]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/sales.sh")

  tags = {
    Name = "Fleet_2 [${count.index + 1}]"
  }
}

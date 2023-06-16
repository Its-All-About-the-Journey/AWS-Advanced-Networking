resource "aws_instance" "VPC_A_Public_Instance" {
  ami                         = "ami-0b029b1931b347543"
  instance_type               = "t2.micro"
  tenancy                     = "default"
  availability_zone           = "us-west-2a"
  key_name                    = ""
  subnet_id                   = aws_subnet.public_subnet_for_VPC_A_AZ_2A.id
  security_groups             = ["${aws_security_group.VPC_A_SG.id}"]
  associate_public_ip_address = true

  tags = {
    "name" = "VPC_A_Private_Instance"
  }
}

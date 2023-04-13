resource "aws_instance" "Consumer_VPC_Public_Instance" {
  ami                         = "ami-0b029b1931b347543"
  instance_type               = "t2.micro"
  tenancy                     = "default"
  availability_zone           = "us-west-2a"
  key_name                    = "CharlesUneze"
  subnet_id                   = aws_subnet.public_subnet_for_Consumer_VPC_AZ_2A.id
  security_groups             = ["${aws_security_group.Consumer_VPC_SG.id}"]
  associate_public_ip_address = true

  tags = {
    "name" = "Consumer_VPC_Public_Instance"
  }
}
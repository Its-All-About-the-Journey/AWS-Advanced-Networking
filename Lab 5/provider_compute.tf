resource "aws_instance" "Provider_VPC_Private_Instance" {
  ami                         = "ami-0b029b1931b347543"
  instance_type               = "t2.micro"
  tenancy                     = "default"
  availability_zone           = "us-west-2a"
  key_name                    = ""
  subnet_id                   = aws_subnet.private_subnet_for_Provider_VPC_AZ_2A.id
  security_groups             = ["${aws_security_group.Provider_VPC_SG.id}"]
  

  tags = {
    "name" = "Provider_VPC_Private_Instance"
  }
}

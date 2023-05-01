resource "aws_instance" "VPC_A_Private_Instance_Acct_2" {
  ami                         = "ami-0b029b1931b347543"
  instance_type               = "t2.micro"
  tenancy                     = "default"
  availability_zone           = "us-west-2a"
  key_name                    = ""
  subnet_id                   = aws_subnet.private_subnet_for_VPC_A_AZ_2A_Acct_2.id
  security_groups             = ["${aws_security_group.VPC_A_SG_Acct_2.id}"]
  associate_public_ip_address = false
  provider                    = aws.Account_2

  tags = {
    "name" = "VPC_A_Private_Instance_Acct_2"
  }
}

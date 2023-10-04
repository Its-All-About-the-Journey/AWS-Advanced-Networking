resource "aws_instance" "Instance" {
  count             = 2
  ami               = "ami-00b7cc7d7a9f548ea" # Amazon Linux
  instance_type     = "t3.micro"
  tenancy           = "default"
  security_groups   = [aws_security_group.SG.id]

  subnet_id = count.index % 2 == 0 ? aws_subnet.public_subnet_for_My_VPC_AZ_2A.id : aws_subnet.public_subnet_for_My_VPC_AZ_2B.id
  key_name  = ""
  user_data = file("${path.module}/script.sh")
  associate_public_ip_address = true

  tags = {
    "Name" = "Instance [${count.index + 1}]"
  }
}

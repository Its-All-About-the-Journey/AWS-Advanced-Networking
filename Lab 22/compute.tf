resource "aws_instance" "Instance" {
  ami                = "ami-00b7cc7d7a9f548ea" # Amazon Linux
  instance_type      = "t3.micro"
  availability_zone  = "us-west-2a"
  tenancy            = "default"
  security_groups    = [aws_security_group.SG.id]
  ipv6_address_count = 1
  subnet_id          = aws_subnet.Private.id
  key_name = ""

  tags = {
    "Name" = "Instance"
  }
}


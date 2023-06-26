resource "aws_security_group" "CSR_SG" {
  name        = "CSR_SG"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.Connect_VPC.id

  ingress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "GRE"
    from_port   = 47
    to_port     = 47
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "CSR_SG"
  }
}


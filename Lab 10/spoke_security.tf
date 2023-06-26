resource "aws_security_group" "VPC_A_SG" {
  name        = "VPC_A_SG"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.VPC_A.id

  ingress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
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
    Name = "VPC_A_SG"
  }
}


resource "aws_security_group" "VPC_B_SG" {
  provider    = aws.us-west-1
  name        = "VPC_B_SG"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.VPC_B.id

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
    Name = "VPC_B_SG"
  }
}

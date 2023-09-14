resource "aws_ec2_instance_connect_endpoint" "APP1" {
  subnet_id          = aws_subnet.APP1_AZ_2A.id
  security_group_ids = [aws_security_group.Workload_VPC_SG.id]

  tags = {
    name = "APP1"
  }
}

resource "aws_ec2_instance_connect_endpoint" "APP2" {
  subnet_id          = aws_subnet.APP2_AZ_2B.id
  security_group_ids = [aws_security_group.Workload_VPC_SG.id]

  tags = {
    name = "APP2"
  }
}

resource "aws_security_group" "Workload_VPC_SG" {
  name        = "Workload_VPC_SG"
  description = "Allow SSH, HTTP and HTTPS and ICMP inbound traffic"
  vpc_id      = aws_vpc.Workload_VPC.id

  ingress {
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP into VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS into VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP into VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Workload_VPC_SG"
  }
}

resource "aws_security_group" "Security_VPC_SG" {
  name        = "SG"
  description = "Allow SSH, HTTP and HTTPS and ICMP inbound traffic"
  vpc_id      = aws_vpc.Security_VPC.id

  ingress {
    description = "SSH into VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP into VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS into VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP into VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Geneve into VPC"
    from_port   = 6081
    to_port     = 6081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security_VPC_SG"
  }
}




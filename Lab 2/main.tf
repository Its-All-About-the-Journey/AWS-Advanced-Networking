# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
  access_key = ""
  secret_key = ""
}

resource "aws_vpc" "VPC_A" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "VPC_A"
  }
}

resource "aws_internet_gateway" "VPC_A_IGW" {
  vpc_id = aws_vpc.VPC_A.id

  tags = {
    Name = "VPC_A_IGW"
  }
}

resource "aws_subnet" "VPC_A_Public_Subnet_A" {
  vpc_id                  = aws_vpc.VPC_A.id
  cidr_block              = "10.0.20.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "VPC_A_Public_Subnet_A"
  }
}

resource "aws_route_table" "VPC_A_Public_RT_A" {
  vpc_id = aws_vpc.VPC_A.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.VPC_A_IGW.id
  }

  tags = {
    Name = "VPC_A_Public_RT_A"
  }
}

resource "aws_route_table_association" "VPC_A_Public_RT_A_Association_A" {
  subnet_id      = aws_subnet.VPC_A_Public_Subnet_A.id
  route_table_id = aws_route_table.VPC_A_Public_RT_A.id
}

resource "aws_instance" "Bastion" {
  ami               = "ami-08cd358d745620807"
  instance_type     = "t2.micro"
  availability_zone = "eu-west-2a"
  key_name          = ""
  tenancy           = "default"
  subnet_id         = aws_subnet.VPC_A_Public_Subnet_A.id
  security_groups   = ["${aws_security_group.SG_Bastion.id}"]

  tags = {
    "name" = "Bastion"
  }
}

resource "aws_security_group" "SG_Bastion" {
  vpc_id      = aws_vpc.VPC_A.id
  description = " SG for bastion host. SSH access only"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "name" = "SG_Bastion"
  }

}

resource "aws_subnet" "VPC_A_Private_Subnet_A" {
  vpc_id                  = aws_vpc.VPC_A.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "VPC_A_Private_Subnet_A"
  }
}

resource "aws_route_table" "VPC_A_Private_RT_A" {
  vpc_id = aws_vpc.VPC_A.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NAT_GW.id
  }

  tags = {
    Name = "VPC_A_Private_RT_A"
  }
}

resource "aws_route_table_association" "VPC_A_Private_RT_A_Association" {
  subnet_id      = aws_subnet.VPC_A_Private_Subnet_A.id
  route_table_id = aws_route_table.VPC_A_Private_RT_A.id
}

resource "aws_default_network_acl" "Default_VPC_A_NACL" {
  default_network_acl_id = aws_vpc.VPC_A.default_network_acl_id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    "name" = "Default_VPC_A_NACL"
  }
}

resource "aws_network_acl" "VPC_A_Private_NACL_A" {
vpc_id = aws_vpc.VPC_A.id
subnet_ids = [aws_subnet.VPC_A_Private_Subnet_A.id]

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    "name" = "VPC_A_Private_NACL_A"
  }
}

resource "aws_network_acl_association" "VPC_A_Private_NACL_A_Association" {
  network_acl_id = aws_network_acl.VPC_A_Private_NACL_A.id
  subnet_id      = aws_subnet.VPC_A_Private_Subnet_A.id
}

resource "aws_instance" "VPC_A_Private_Subnet_A_Instance_A" {
  ami               = "ami-08cd358d745620807"
  instance_type     = "t2.micro"
  availability_zone = "eu-west-2a"
  key_name          = ""
  tenancy           = "default"
  subnet_id         = aws_subnet.VPC_A_Private_Subnet_A.id
  security_groups   = ["${aws_security_group.SG_Private.id}"]

  tags = {
    "name" = "VPC_A_Private_Subnet_A_Instance_A"
  }
}

resource "aws_security_group" "SG_Private" {
  name        = "SG_Private"
  description = "Security group for private subnet instances."
  vpc_id      = aws_vpc.VPC_A.id

  ingress {
    description     = "Accept SSH inbound requests from Bastion host only."
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Outgoing ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "name" = "SG_Private"
  }
}


resource "aws_eip" "EIP_for_NAT_GW" {
  vpc = true
}

resource "aws_nat_gateway" "NAT_GW" {
  subnet_id         = aws_subnet.VPC_A_Public_Subnet_A.id
  connectivity_type = "public"
  allocation_id     = aws_eip.EIP_for_NAT_GW.id

  tags = {
    "Name" = "NAT_GW"
  }
}
